{
  lib,
  modulesPath,
  ...
}: let
  nixosDisk = "/dev/disk/by-label/nixos";

  btrfsSubvolume = subvolume: {
    device = nixosDisk;
    fsType = "btrfs";
    options = [
      "subvol=${subvolume}"
      "compress=zstd"
      "noatime"
      "discard=async"
    ];
  };
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Replace or extend these with the modules detected by
  # nixos-generate-config on the ThinkPad before installation.
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "usbhid"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems = {
    "/" = btrfsSubvolume "root";
    "/nix" = btrfsSubvolume "nix";
    "/home" = btrfsSubvolume "home";
    "/boot" = {
      device = "/dev/disk/by-partlabel/EFI";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
