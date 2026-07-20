import { randomUUID } from 'node:crypto'
import fs from 'node:fs'
import path from 'node:path'
import process from 'node:process'

const runtime = Object.freeze({
  bash: '@bashBinary@',
  compose: '@composeBinary@',
  git: '@gitBinary@',
  ssh: '@sshBinary@',
  home: '@deployHome@',
  user: '@deployUser@',
  path: '@runtimePath@',
  gitDirectory: '/srv/Repo',
  workTree: '/srv',
  remoteRef: 'refs/remotes/origin/main',
  notify: '/run/current-system/sw/bin/notify-ntfy-maintenance',
})

const requestPattern = /^deploy ([0-9a-f]{40}) (all|[A-Za-z0-9_-]+(?:\/[A-Za-z0-9_-]+)*)$/
const stackPattern = /^[A-Za-z0-9_-]+(?:\/[A-Za-z0-9_-]+)*$/

class UsageError extends Error {}

const execute = $({
  shell: runtime.bash,
  verbose: false,
  env: {
    DOCKER_CONFIG: path.join(runtime.home, '.docker'),
    GIT_CONFIG_NOSYSTEM: '1',
    GIT_SSH_COMMAND: `${runtime.ssh} -oBatchMode=yes -oStrictHostKeyChecking=yes`,
    GIT_TERMINAL_PROMPT: '0',
    HOME: runtime.home,
    LANG: 'C.UTF-8',
    LC_ALL: 'C.UTF-8',
    LOGNAME: runtime.user,
    PATH: runtime.path,
    TMPDIR: '/tmp',
    USER: runtime.user,
  },
})

function log(message) {
  console.log(`${new Date().toISOString()} ${message}`)
}

function requestFromInput() {
  const localArgumentsArePlain = Object.keys(argv).every(key => key === '_')
  const raw = process.env.SSH_ORIGINAL_COMMAND ??
    (localArgumentsArePlain ? argv._.join(' ') : '')
  const match = raw.length <= 256 && requestPattern.exec(raw)
  if (!match) throw new UsageError('expected deploy <40-character-sha> <all|stack-path>')
  return { commit: match[1], selection: match[2] }
}

function selectedStacks(source, selection) {
  let manifest
  try {
    manifest = JSON.parse(source)
  } catch (error) {
    throw new Error(`invalid stacks.json: ${error.message}`)
  }

  if (manifest?.version !== 1 || !Array.isArray(manifest.stacks)) {
    throw new Error('unsupported stacks.json')
  }

  const stacks = manifest.stacks.map(stack => stack?.path)
  if (
    stacks.length === 0 ||
    stacks.some(stack => typeof stack !== 'string' || !stackPattern.test(stack)) ||
    new Set(stacks).size !== stacks.length
  ) {
    throw new Error('stacks.json contains invalid or duplicate stack paths')
  }

  if (selection === 'all') return stacks
  if (!stacks.includes(selection)) throw new Error(`unknown stack: ${selection}`)
  return [selection]
}

function gitArguments(...args) {
  return [
    `--git-dir=${runtime.gitDirectory}`,
    `--work-tree=${runtime.workTree}`,
    '-c', 'core.hooksPath=/dev/null',
    '-c', 'protocol.ext.allow=never',
    ...args,
  ]
}

async function run(stage, binary, args, timeout, capture = false) {
  log(stage)
  const options = capture
    ? { nothrow: true, timeout, quiet: true }
    : { nothrow: true, timeout, stdio: 'inherit' }
  const result = await execute(options)`${binary} ${args}`

  if (!result.ok) {
    const status = result.exitCode ?? result.signal ?? 'unknown status'
    const detail = capture ? String(result.stderr ?? '').trim().slice(0, 2048) : ''
    throw new Error(`${stage} failed (${status})${detail ? `: ${detail}` : ''}`)
  }

  return capture ? String(result.stdout) : undefined
}

async function requireCleanWorkTree() {
  log('checking tracked work tree')
  for (const extra of [[], ['--cached']]) {
    const result = await execute({ nothrow: true, timeout: 60_000, quiet: true })
      `${runtime.git} ${gitArguments('diff', ...extra, '--quiet', '--ignore-submodules', '--')}`
    if (result.exitCode === 1) {
      throw new Error(`tracked files in ${runtime.workTree} contain local changes`)
    }
    if (!result.ok) throw new Error('checking tracked work tree failed')
  }
}

function acquireLock() {
  const lockPath = path.join(runtime.gitDirectory, 'obsidian-deploy.lock')
  const token = `${process.pid}:${randomUUID()}`

  try {
    fs.writeFileSync(lockPath, token, { flag: 'wx', mode: 0o600 })
  } catch (error) {
    if (error.code !== 'EEXIST') throw error

    const owner = Number.parseInt(fs.readFileSync(lockPath, 'utf8'), 10)
    try {
      process.kill(owner, 0)
      throw new Error('another deployment is already running')
    } catch (processError) {
      if (processError.code !== 'ESRCH') throw processError
    }

    fs.unlinkSync(lockPath)
    fs.writeFileSync(lockPath, token, { flag: 'wx', mode: 0o600 })
  }

  return () => {
    try {
      if (fs.readFileSync(lockPath, 'utf8') === token) fs.unlinkSync(lockPath)
    } catch (error) {
      if (error.code !== 'ENOENT') throw error
    }
  }
}

async function deploy(request) {
  await run(
    'fetching origin/main',
    runtime.git,
    gitArguments('fetch', 'origin', `+refs/heads/main:${runtime.remoteRef}`),
    120_000,
  )
  await run(
    'verifying requested commit',
    runtime.git,
    gitArguments('cat-file', '-e', `${request.commit}^{commit}`),
    60_000,
  )
  await run(
    'verifying origin/main ancestry',
    runtime.git,
    gitArguments('merge-base', '--is-ancestor', request.commit, runtime.remoteRef),
    60_000,
  )

  const manifest = await run(
    'reading stacks.json',
    runtime.git,
    gitArguments('show', `${request.commit}:stacks.json`),
    60_000,
    true,
  )
  const stacks = selectedStacks(manifest, request.selection)

  await requireCleanWorkTree()
  await run(
    `checking out ${request.commit}`,
    runtime.git,
    gitArguments('checkout', '--detach', '--no-overwrite-ignore', request.commit),
    120_000,
  )

  const plans = stacks.map(stack => {
    const directory = path.join(runtime.workTree, ...stack.split('/'))
    const compose = ['--project-directory', directory, '-f', path.join(directory, 'compose.yml')]
    return [
      [`validating ${stack}`, [...compose, 'config', '--quiet'], 60_000],
      [`pulling ${stack}`, [...compose, 'pull'], 900_000],
      [
        `starting ${stack}`,
        [
          ...compose,
          'up', '--detach', '--pull', 'never', '--no-build',
          '--wait', '--wait-timeout', '180',
        ],
        240_000,
      ],
    ]
  })

  for (let stage = 0; stage < 3; stage += 1) {
    for (const plan of plans) {
      await run(plan[stage][0], runtime.compose, plan[stage][1], plan[stage][2])
    }
  }

  log(`deployment succeeded: ${request.commit} (${request.selection})`)
}

async function notify(status, priority, message) {
  const result = await execute({ nothrow: true, timeout: 20_000, quiet: true })
    `${runtime.notify} ${[`obsidian: deployment ${status}`, 'gear', priority, message]}`
  if (!result.ok) log(`warning: ntfy notification failed (${result.exitCode})`)
}

let releaseLock
let exitCode = 0

try {
  const request = requestFromInput()
  releaseLock = acquireLock()
  await deploy(request)
  await notify('succeeded', 'default', `Commit: ${request.commit}; selection: ${request.selection}`)
} catch (error) {
  log(`error: ${error.message}`)
  if (error instanceof UsageError) {
    exitCode = 64
  } else {
    exitCode = 1
    await notify('failed', 'high', error.message)
  }
} finally {
  releaseLock?.()
}

process.exitCode = exitCode
