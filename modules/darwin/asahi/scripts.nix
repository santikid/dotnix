{pkgs, ...}: [
  (
    pkgs.writeShellApplication {
      name = "rebootme";
      text = ''
        #!/bin/bash
        set +u

        if [ -z "$1" ]; then
          echo "usage: $0 (nix|mac)"
          exit 1
        fi
        case $1 in
          nix)
            sudo bless --mount "/Volumes/NixOS" --setBoot --nextonly
          ;;
          mac)
            sudo bless --mount "/Volumes/Macintosh HD" --setBoot --nextonly
          ;;
        *)
          echo "usage: $0 (nix|mac)"
          exit 1
        ;;
        esac
        sudo reboot
      '';
    }
  )
]
