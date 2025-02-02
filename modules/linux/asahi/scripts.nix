{pkgs, ...}:
with pkgs; [
  (
    pkgs.writeShellApplication {
      name = "rebootme";
      runtimeInputs = with pkgs; [asahi-bless];
      text = ''
        #!/bin/bash
        set +u

        if [ -z "$1" ]; then
          echo "usage: $0 (nix|mac)"
          exit 1
        fi
        case $1 in
          nix)
            sudo asahi-bless --next --set-boot "NixOS" --yes
          ;;
          mac)
            sudo asahi-bless --next --set-boot "Macintosh HD" --yes
          ;;
        *)
          echo "usage: $0 (nix|mac)"
          exit 1
        ;;
        esac
        reboot
      '';
    }
  )
]
