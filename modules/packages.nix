{pkgs, ...}: let
  opencode =
    if pkgs.stdenv.hostPlatform.isDarwin
    then
      pkgs.opencode.overrideAttrs (oldAttrs: {
        nativeBuildInputs =
          oldAttrs.nativeBuildInputs
          ++ [pkgs.darwin.autoSignDarwinBinariesHook];

        # OpenCode tries to execute Bun's generated Mach-O before Nix's Darwin
        # signing hook runs, so macOS rejects it and kills the smoke test with 137.
        postPatch =
          (oldAttrs.postPatch or "")
          + ''
            substituteInPlace packages/opencode/script/build.ts \
              --replace-fail \
                '  if (item.os === process.platform && item.arch === process.arch && !item.abi) {' \
                '  if (false && item.os === process.platform && item.arch === process.arch && !item.abi) {'
          '';

        # Sign the binary and repeat the skipped upstream smoke test.
        postBuild =
          (oldAttrs.postBuild or "")
          + ''
            signIfRequired dist/opencode-*/bin/opencode
            dist/opencode-*/bin/opencode --version
          '';
      })
    else pkgs.opencode;
in {
  environment.systemPackages = [
    # Base tools
    pkgs.age
    pkgs.ncdu
    pkgs.jq
    pkgs.ripgrep
    pkgs.fzf
    pkgs.gh
    pkgs.nixd
    pkgs.pandoc
    pkgs.htop
    pkgs.btop
    pkgs.mosh

    # Development
    pkgs.python3
    pkgs.cmake
    pkgs.nodejs_24
    pkgs.pnpm_11
    opencode
    pkgs.bun
    pkgs.oxlint
    pkgs.prettier
    pkgs.svelte-language-server
    pkgs.typescript
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted
    pkgs.rustc
    pkgs.cargo
    pkgs.rustfmt
    pkgs.clippy
    pkgs.rust-analyzer
    pkgs.pkg-config
    pkgs.bacon

    # Media and backup
    pkgs.ffmpeg
    pkgs.imagemagick
    pkgs.borgbackup

    (pkgs.writeShellApplication {
      name = "ts";
      runtimeInputs =
        [
          pkgs.coreutils
          pkgs.findutils
          pkgs.fzf
          pkgs.tmux
        ]
        ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
          pkgs.procps
        ];
      text = ''
        set +e
        set +o nounset

        if [[ $# -eq 1 ]]; then
          selected=$1
        else
          selected=$(find ~/Projects/co ~/Projects/p ~/Projects/w -mindepth 1 -maxdepth 1 -type d | fzf)
        fi

        if [[ -z $selected ]]; then
          exit 0
        fi

        selected_name=$(basename "$selected" | tr . _)
        tmux_running=$(pgrep tmux)

        if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
          tmux new-session -s "$selected_name" -c "$selected"
          exit 0
        fi

        if ! tmux has-session -t="$selected_name" 2> /dev/null; then
          tmux new-session -ds "$selected_name" -c "$selected"
        fi

        if [[ -z $TMUX ]]; then
          tmux attach -t "$selected_name"
          exit 0
        fi

        tmux switch-client -t "$selected_name"
      '';
    })
  ];
}
