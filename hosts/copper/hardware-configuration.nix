{lib, ...}: {
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "sr_mod"
    "virtio_blk"
    "virtio_pci"
    "virtio_scsi"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
