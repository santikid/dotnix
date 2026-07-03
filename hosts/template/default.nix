{
  imports = [
    ./hardware-configuration.nix
  ];

  # Copy this directory to hosts/<name> and set the host system in flake.nix.
  # Keep host-specific hardware, disks, boot, and services here; prefer shared
  # roles from modules/ for repeated behavior.
  system.stateVersion = "26.05";
}
