{pkgs, ...}: {
  homebrew.casks = [
    "secretive"
    "iina"
    "zen"
  ];

  environment.systemPackages = with pkgs; [
    lazygit

    (writeShellApplication {
      name = "cpc";
      runtimeInputs = [openssh];
      text = ''
        set -euo pipefail

        host=''${COPPER_HOST:-copper}
        display=''${COPPER_WAYLAND_DISPLAY:-wayland-1}

        case "$display" in
          "" | *[!A-Za-z0-9._-]*)
            echo "invalid WAYLAND_DISPLAY: $display" >&2
            exit 2
            ;;
        esac

        remote_env="export PATH=/run/current-system/sw/bin:\$PATH; export XDG_RUNTIME_DIR=/run/user/\\\$(id -u); export WAYLAND_DISPLAY=$display;"

        usage() {
          echo "usage: cpc push|pull" >&2
          exit 2
        }

        case "''${1:-}" in
          push)
            pbpaste | ssh -o BatchMode=yes "$host" "$remote_env wl-copy"
            ;;
          pull)
            ssh -o BatchMode=yes "$host" "$remote_env wl-paste --no-newline 2>/dev/null" | pbcopy
            ;;
          *)
            usage
            ;;
        esac
      '';
    })

    # LSP
    svelte-language-server
    typescript-language-server
    typescript
    rust-analyzer
    vscode-langservers-extracted
  ];
}
