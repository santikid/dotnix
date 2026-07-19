{lib, ...}: let
  firmwarelessCI =
    builtins.getEnv "SANTISASAHI_FIRMWARELESS_CI" == "1";

  nixosDisk = "/dev/disk/by-label/nixos";

  btrfsSubvolume = subvol: {
    device = nixosDisk;
    fsType = "btrfs";
    options = ["subvol=${subvol}" "compress=zstd" "noatime"];
  };
in {
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  boot.supportedFilesystems = ["btrfs"];

  fileSystems = {
    "/" = btrfsSubvolume "root";
    "/nix" = btrfsSubvolume "nix";
    "/home" = btrfsSubvolume "home";
    "/boot" = {
      device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  swapDevices = [];
  zramSwap.enable = true;

  hardware = {
    asahi =
      {
        enable = true;
        extractPeripheralFirmware = !firmwarelessCI;
      }
      // lib.optionalAttrs firmwarelessCI {
        peripheralFirmwareDirectory = null;
      };
    sensor.iio.enable = true;
    bluetooth.enable = true;
  };
}
