{
  config,
  lib,
  modulesPath,
  ...
}: let
  btrfsDevice = "/dev/disk/by-label/opal";
  btrfsSubvolume = subvolume: {
    device = btrfsDevice;
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

  boot.initrd.availableKernelModules = [
    "nvme"
    "sd_mod"
    "uas"
    "usb_storage"
    "usbhid"
    "xhci_pci"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems = {
    "/" = btrfsSubvolume "@root";
    "/nix" = btrfsSubvolume "@nix";
    "/home" = btrfsSubvolume "@home";
    "/var/log" = btrfsSubvolume "@log";
    "/var/lib/docker" = btrfsSubvolume "@docker";
    "/boot-a" = {
      device = "/dev/disk/by-label/OPAL-ESP-A";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
    "/boot-b" = {
      device = "/dev/disk/by-label/OPAL-ESP-B";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  swapDevices = [];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
