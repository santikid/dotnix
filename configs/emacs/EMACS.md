# Emacs Configuration Guide

Modern vim-like Emacs setup with Evil mode, LSP, and powerful completion.

### Install Icons

```
M-x all-the-icons-install-fonts
```

### Configure AI

Add to `~/.authinfo`:
```
machine api.anthropic.com password sk-ant-YOUR-KEY
```

### Configure Forge (GitHub/Forgejo)

Forge lets you manage PRs, issues, and code review from Emacs.

**GitHub:**

1. Create a token at https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Select scopes: `repo` (full), `read:org`, `notifications`
2. Add to `~/.authinfo`:
   ```
   machine api.github.com login YOUR_USERNAME^forge password ghp_YOUR_TOKEN
   ```

**Forgejo/Gitea:**

1. Go to your instance → Settings → Applications → Generate New Token
   - Select scopes: `repo`, `issue`, `organization`, `user`
2. Add to `~/.authinfo`:
   ```
   machine your-forgejo.example.com login YOUR_USERNAME^forge password YOUR_TOKEN
   ```
3. Tell Forge about your instance (add to config.org):
   ```elisp
   (with-eval-after-load 'forge
     (add-to-list 'forge-alist '("your-forgejo.example.com"
                                  "your-forgejo.example.com/api/v1"
                                  "your-forgejo.example.com"
                                  forge-gitea-repository)))
   ```

**First use:**
1. Open a repo with `SPC g g` (magit-status)
2. Press `SPC g f F` to fetch PRs/issues (first fetch takes a moment)
3. Now `SPC g f p` and `SPC g f i` will show your PRs and issues

**Note:** Keep `~/.authinfo` secure (`chmod 600 ~/.authinfo`) or use `~/.authinfo.gpg` for encryption.

## Essential Keybindings

### Core Vim Operations

All standard vim keybindings work: `hjkl`, `w/b/e`, `d/c/y/p`, `u/Ctrl-r`, `v/V`, `/`, etc.

**Vim commands:**
- `:w` - Save
- `:q` - Quit window
- `:wq` - Save and quit

**Surround:**
- `ysiw"` - Surround word with "
- `cs"'` - Change " to '
- `ds"` - Delete surrounding "

**Commentary:**
- `gcc` - Comment/uncomment line
- `gc` - Comment motion/selection

**Multiple Cursors:**
- `M-d` - Select next occurrence (like Cmd+D in VSCode)
- `M-D` - Select previous occurrence
- `C-M-d` - Select all occurrences
- Edit all simultaneously, `ESC` to exit

**Undo:**
- `u` - Undo
- `Ctrl-r` - Redo
- `SPC u` - Visual undo tree (navigate history with j/k, q to quit)

### Leader Key: `SPC`

Press `SPC` and wait - which-key shows all options.

#### Files & Buffers
- `SPC f f` - Find file
- `SPC f w` - Write (save) file
- `SPC f r` - Recent files
- `SPC b` - Switch buffer (fuzzy search)
- `SPC k` - Kill buffer

#### Windows
- `C-h/j/k/l` - Navigate windows (use `SPC w w` for treemacs)
- `SPC s v` - Split vertical
- `SPC s h` - Split horizontal
- `SPC w d` - Delete window
- `SPC w w` - Select window by label (ace-window)

#### Search & Navigation
- `SPC f s` - Ripgrep search
- `SPC f l` - Search current buffer
- `SPC j j` - Jump to character (avy)
- `SPC p f` - Find file in project
- `SPC p s` - Search in project

#### Git (Magit)
- `SPC g g` - Magit status (main git interface)
- `SPC g d` - Diff current file
- `SPC g b` - Blame
- `SPC g t` - Git timemachine

#### Forge (GitHub/Forgejo)
- `SPC g f f` - Forge menu (dispatch)
- `SPC g f p` - List pull requests
- `SPC g f i` - List issues
- `SPC g f c` - Create pull request
- `SPC g f C` - Create issue
- `SPC g f F` - Fetch forge data (PRs, issues)
- `SPC g f b` - Browse repo in browser
- `SPC g f B` - Browse current PR/issue in browser

#### LSP (Code)
- `K` - Show documentation (popup)
- `g d` - Go to definition
- `g r` - Find references
- `g i` - Go to implementation
- `SPC c a` - Code actions
- `SPC c r` - Rename symbol
- `SPC = =` - Format buffer

#### Diagnostics
- `SPC x x` - Show all diagnostics
- `SPC x n` - Next error
- `SPC x p` - Previous error

#### Projects
- `SPC p p` - Switch project
- `SPC p f` - Find file in project
- `SPC p b` - Switch to project buffer

#### Treemacs (File Tree)
- `SPC e` - Toggle treemacs
- `SPC 0` - Jump to treemacs
- In treemacs: `j/k` navigate, `h/l` collapse/expand, `RET` open, `c` create, `d` delete, `R` rename, `q` close

#### Terminal
- `SPC t t` - Open new terminal (vterm)
- `SPC t T` - Open terminal in split
- `SPC t p` - Project terminal (one per project)
- `SPC t l` - List/switch between terminals
- `C-\`` - Toggle popup terminal

#### Org & Notes
- `SPC o a` - Org agenda
- `SPC o c` - Quick capture (task/note/journal)
- `SPC o r` - Refile item to another file
- `SPC n f` - Find/create note (org-roam)
- `SPC n i` - Insert note link
- `SPC n b` - Toggle backlinks buffer
- `SPC n d` - Today's daily note
- `SPC n y` - Yesterday's daily note

#### GPTel
- `SPC i c` - Start AI chat
- `SPC i s` - Send selection to AI
- `SPC i m` - GPTel menu

#### Claude Code (claude-code.el)

**Instance Management:**
- `SPC a a` - Start Claude in project root
- `SPC a d` - Start in specified directory
- `SPC a C` - Resume previous conversation
- `SPC a R` - Resume from session list
- `SPC a k` - Kill current Claude session
- `SPC a K` - Kill all instances

**Sending Content:**
- `SPC a s` - Send command via minibuffer
- `SPC a x` - Send command with file/line context
- `SPC a r` - Send selected region or buffer
- `SPC a o` - Send current file
- `SPC a e` - Fix error at point (flycheck/flymake)

**Window Management:**
- `SPC a t` - Toggle Claude window
- `SPC a b` - Switch to Claude buffer
- `SPC a B` - Select from all instances
- `SPC a z` - Toggle read-only mode (for copying)

**Quick Responses:**
- `SPC a y` - Send "Yes" confirmation
- `SPC a n` - Send "No" or cancel
- `SPC a 1/2/3` - Send numbered responses

**Other:**
- `SPC a m` - Transient menu (shows all commands)
- `SPC a f` - Fork conversation
- `SPC a /` - Slash commands
- `SPC a M` - Cycle between modes

**Multiple Instances:**
- First instance per directory is "default"
- Additional instances get custom names (e.g., "tests", "docs")
- Buffer naming: `*claude:/path/to/directory:instance-name*`

#### Help
- `SPC h f` - Describe function
- `SPC h v` - Describe variable
- `SPC h k` - Describe key

#### Workspaces
- `SPC TAB TAB` - Switch workspace
- `SPC TAB n/p` - Next/previous workspace

### Essential Emacs Keys

- `C-g` - Cancel/escape (use this often!)
- `M-x` - Execute command (or `SPC SPC`)
- `C-h k` - Describe key (press, then any key to see what it does)

## Core Concepts

### Buffers
Everything is a buffer: files, terminals, git, help pages. Use `SPC b` to switch between them.

### Windows vs Frames
- **Window** = pane/split (like vim splits)
- **Frame** = OS window
- Split windows, not frames

### Minibuffer
The floating prompt that appears when you press `M-x`, `SPC f f`, etc. (powered by vertico-posframe)

## Magit Workflow

1. `SPC g g` - Open magit-status
2. `j/k` - Navigate files/hunks
3. `s` - Stage, `u` - Unstage
4. `c c` - Commit (type message, `C-c C-c` to confirm)
5. `P p` - Push
6. `?` - Help (shows all commands)
7. `TAB` - Expand/collapse sections

**Common commands in magit:**
- `d d` - Diff
- `l l` - Log
- `b b` - Switch branch
- `F p` - Pull
- `z` - Stash

## Buffer Navigation

- `SPC b` - Switch buffer (fuzzy search, fastest method)
- `SPC p b` - Switch to project buffer
- `SPC k` - Kill current buffer
- `:q` - Close window (doesn't kill buffer)

**Unique buffer names:** Files with the same name show their parent directory (e.g., `routes/+page.svelte` vs `admin/+page.svelte`).

Emacs philosophy: Use fuzzy search (`SPC b`) instead of cycling through buffers.

## Configuration Management

### Editing Config

1. `SPC f f ~/.emacs.d/config.org`
2. Edit the org file
3. Save and restart (`SPC q r`)

Or apply without restart:
```
M-x org-babel-tangle
M-x load-file RET ~/.emacs.d/config.el RET
```

### Package Management

- `M-x straight-pull-all` - Update packages
- `M-x straight-rebuild-all` - Rebuild packages

## Troubleshooting

### LSP not working
1. Check language server installed
2. `M-x eglot` to manually start
3. Check `*EGLOT ... stderr*` buffer for errors

### Keybinding not working
- `C-h k` then press the key to see what it's bound to

### General debugging
- Start with `emacs --debug-init` to see startup errors
- Check `*Messages*` buffer (`SPC b` then search Messages)
- `C-g` cancels everything

### Clean slate
```bash
rm -rf ~/.emacs.d/straight/
# Restart Emacs to reinstall
```

## Key Differences from Vim

### Philosophy
- **Vim:** Modal editing, minimal by default
- **Emacs:** Extensible environment, everything is a buffer
- **This config:** Vim editing + Emacs power

### Buffers
- Emacs buffers persist after closing windows
- Use `SPC k` to actually close a buffer
- `:q` only closes the window

### Discovery
- `SPC` + wait → see all commands (which-key)
- `C-h k` → describe any key
- `M-x` → searchable command palette

## Pro Tips

1. **Use `C-g` liberally** - Cancels everything, gets you unstuck
2. **Let which-key guide you** - Press `SPC` and explore
3. **`SPC b` is your friend** - Faster than cycling buffers
4. **Magit is powerful** - Spend time learning it
5. **Use `SPC w w` (ace-window)** - Better than `C-hjkl` for many splits
6. **Multiple cursors** - `M-d` to select next occurrence, huge time saver
7. **Treemacs follows you** - Auto-expands to current file
8. **Auto-save enabled** - Files save automatically when switching buffers/windows
9. **Visual undo** - `SPC u` to see your edit history as a tree

## Quick Reference

| Action | Key |
|--------|-----|
| Save | `:w` or `SPC f w` |
| Undo/Redo | `u` / `Ctrl-r` |
| Visual undo tree | `SPC u` |
| Find file | `SPC f f` |
| Switch buffer | `SPC b` |
| Search project | `SPC p s` |
| Git status | `SPC g g` |
| LSP actions | `SPC c a` |
| Jump to char | `SPC j j` |
| Toggle tree | `SPC e` |
| Terminal | `SPC t t` |
| Help | `C-h k` |
| Cancel | `C-g` |
| Command palette | `M-x` or `SPC SPC` |

## Org-mode: Your External Brain

Org-mode is perfect for managing information when you need external organization support. Think of it as a text-based system for capturing everything.

### Getting Started

**Create your notes directory:**
```bash
mkdir -p ~/org
```

**File structure (hybrid approach):**
```
~/org/
├── inbox.org          # Quick note captures
├── tasks.org          # Main TODO list (agenda)
├── projects.org       # Project planning (agenda)
├── journal.org        # Journal captures
├── archive.org        # Completed items
└── notes/             # Zettelkasten notes (org-roam)
    └── journal/       # Daily notes (org-roam dailies)
```

### Basic Syntax

**Headings & Structure:**
```org
* Top level heading
** Second level
*** Third level
- Bullet point
- [ ] Checkbox (unchecked)
- [X] Checkbox (checked)
```

**TODO Items:**
```org
* TODO Write documentation
* IN-PROGRESS Working on feature
* DONE Completed task
  CLOSED: [2024-01-15 Mon 14:30]
```

**Cycle TODO states:** `Shift-Right/Left` on a heading

**Links:**
```org
[[file:other-file.org][Description]]
[[https://example.com][Website]]
[[id:note-id][Link to org-roam note]]
```

**Tags & Priorities:**
```org
* TODO [#A] High priority task    :work:urgent:
* DONE [#B] Medium priority        :personal:
```

**Add tag:** `C-c C-q` (or `SPC m q`)
**Set priority:** `C-c ,` (or `SPC m ,`)

### Quick Capture

Press `SPC o c` anytime to capture a thought without interrupting your work:

- **t - Task** - Creates TODO in tasks.org (shows in agenda)
- **n - Note** - Quick note to inbox.org (process later)
- **j - Journal** - Adds entry to journal.org (dated)

This is crucial for ADHD - capture immediately, organize later. When done capturing, press `C-c C-c` to save or `C-c C-k` to cancel.

### TODO Management

**Creating TODOs:**
1. In any .org file, type `* TODO Your task`
2. Or use quick capture: `SPC o c` → select "TODO"

**Organizing tasks:**
- `Shift-Right/Left` - Cycle TODO state (TODO → IN-PROGRESS → DONE)
- `Shift-Up/Down` - Change priority
- `C-c C-t` - Select TODO state directly
- `M-h/l` - Promote/demote heading level

**Checkboxes for subtasks:**
```org
* TODO Complete project
- [ ] Research
- [ ] Write code
- [X] Test
```

Toggle with `C-c C-c` on the checkbox line.

**Refiling (organizing later):**
- Capture to inbox.org throughout the day
- Later: Open inbox.org, move cursor to item, press `SPC o r`
- Choose destination: tasks.org, projects.org, or archive.org
- Keeps your main files organized without interrupting flow

### Org Agenda: Your Command Center

**Open agenda:** `SPC o a`

The agenda shows all your TODOs, scheduled items, and deadlines in one view.

**Scheduling & Deadlines:**
- `C-c C-s` (or `SPC m s`) - Schedule a task
- `C-c C-d` (or `SPC m d`) - Add deadline

```org
* TODO Write blog post
  SCHEDULED: <2024-01-20 Sat>
  DEADLINE: <2024-01-25 Thu>
```

**In agenda view:**
- `j/k` - Navigate
- `t` - Change TODO state
- `RET` - Jump to item
- `s` - Schedule
- `d` - Set deadline
- `q` - Quit

**Agenda views:**
- `d` - Day view
- `w` - Week view
- `v` - View options

### Org-roam: Zettelkasten Notes

For interconnected knowledge base notes (like Obsidian):

**Create/find note:** `SPC n f`
- Type note title, creates if doesn't exist
- One concept per note
- Files stored in `~/org/notes/`

**Insert link to note:** `SPC n i`
- Links notes together
- Org-roam tracks backlinks automatically

**View backlinks:** `SPC n b`
- See all notes that link to current note
- Great for discovering connections

**Daily notes:** `SPC n d`
- Opens today's journal entry
- Perfect for daily logs, meeting notes, thoughts

**Example workflow:**
1. `SPC n d` - Open today's daily note
2. Write meeting notes, thoughts
3. `SPC n i` - Link to relevant project/topic notes
4. Later: `SPC n b` to see what you wrote about that topic

### Tags & Properties

**Add tags:** `C-c C-q`
```org
* Research web frameworks    :research:web:javascript:
```

**Filter in agenda:** Press `m` in agenda view, enter tag query
- `+work` - Has work tag
- `+work-urgent` - Has work, not urgent
- `+work|personal` - Has work OR personal

**Properties (metadata):**
```org
* Project: Website Redesign
:PROPERTIES:
:Client: Acme Corp
:Budget: $5000
:Status: Active
:END:
```

### Daily Workflow Recommendations

Given your needs (aphantasia, ADHD, low working memory), here's a suggested routine:

**Morning:**
1. `SPC n d` - Open daily note
2. `SPC o a` - Check agenda for today's scheduled items
3. Plan 3-5 most important tasks for the day

**Throughout day:**
1. `SPC o c` - Capture thoughts immediately (don't lose them!)
2. Keep daily note open for logging
3. Link related ideas with `SPC n i`

**Evening:**
1. Review daily note
2. Open inbox.org and refile items (`SPC o r`) to tasks.org or projects.org
3. Update TODO states in agenda
4. Schedule tomorrow's tasks

**Weekly:**
1. `SPC o a` then `w` - Week view
2. Review all open TODOs
3. Archive completed items

### Tips for Your Use Case

**External memory strategies:**
- **Capture everything** - Don't trust your working memory
- **Links over memory** - Connect notes instead of remembering connections
- **Agenda is your friend** - One place to see everything
- **Daily notes** - Write down what you did (you'll forget otherwise)
- **Recurring tasks** - Schedule habits so you don't forget them

**ADHD-friendly practices:**
- **Quick capture** - `SPC o c` - Interrupt-free capture
- **One inbox** - Process inbox.org when you have focus
- **Visual cues** - Use priorities [#A] [#B] [#C]
- **Break down tasks** - Use checkboxes for small steps
- **Time blocking** - Schedule specific times in agenda

### Common Org Commands

| Action | Command | Key |
|--------|---------|-----|
| New heading (same level) | | `M-RET` |
| Promote/demote heading | | `M-h` / `M-l` |
| Move heading up/down | | `M-j` / `M-k` |
| Cycle TODO state | | `Shift-Right/Left` |
| Toggle checkbox | | `C-c C-c` |
| Schedule task | | `C-c C-s` |
| Set deadline | | `C-c C-d` |
| Add tag | | `C-c C-q` |
| Org agenda | | `SPC o a` |
| Capture | | `SPC o c` |
| Refile item | | `SPC o r` |
| Archive subtree | | `C-c C-x C-a` |

## Next Steps

1. **Set up org directories:**
   ```bash
   mkdir -p ~/org ~/org/notes ~/org/notes/journal
   touch ~/org/inbox.org ~/org/tasks.org ~/org/projects.org ~/org/journal.org ~/org/archive.org
   ```
2. **Start with daily notes** - `SPC n d` and start journaling
3. **Create your first task** - `SPC o c` then `t` for TODO
4. **Check the agenda** - `SPC o a` to see your tasks
5. **Learn Magit** - `SPC g g` then `?` for help
