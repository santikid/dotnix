# WE SO BACK

# Installing on macOS

1. Install Xcode CLI Tools

`xcode-select --install`

2. Install Nix using the Lix installer

`curl -sSf -L https://install.lix.systems/lix | sh -s -- install`

4. Clone to ~/.nix and install

`git clone https://github.com/santikid/dotnix.git ~/.nix`

`nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.nix#<host>`

# Installing NixOS

Boot up nixos-minimal installer ISO

Optionally load different keymap (e.g. `loadkeys de`)

Format and mount disk to /mnt:

```bash
# using parted
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 1MiB 512MiB
parted /dev/sda -- mkpart primary 512MiB 100%
parted /dev/sda -- name 1 EFI
parted /dev/sda -- name 2 root
parted /dev/sda -- set 1 boot on

# using f/gdisk
# TODO

mkfs.fat -F 32 /dev/sda1
mkfs.ext4 /dev/sda2

mount /dev/disk/by-partlabel/root /mnt
mkdir /mnt/boot
mount /dev/disk/by-partlabel/EFI /mnt/boot
```

(optional for new host) Let NixOS generate hardware config to add as a new host later; skip if using existing machines

`nixos-generate-config --root /mnt`

Clone this repository to /mnt/.nix:

`git clone https://github.com/santikid/dotnix /mnt/.nix`

Install Flake

`nixos-install --flake /mnt/.nix#<machine>`

REBOOT

# Installing Asahi NixOS

Installing an Asahi system is similar to regular NixOS, but the formatting has to be done as explained in `nix-community/nixos-apple-silicon`.

```bash
# Create root partition
sgdisk /dev/nvme0n1 -n 0:0 -s

# Get number of root partition (code 8300), usually 5
sgdisk /dev/nvme0n1 -p

# Format root partition
mkfs.btrfs -L nixos /dev/nvme0n1p5

# Create and mount subvolumes
mount /dev/disk/by-label/nixos /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/home
umount /mnt

mount -o subvol=root,compress=zstd,noatime /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/{nix,home,boot}
mount -o subvol=nix,compress=zstd,noatime /dev/disk/by-label/nixos /mnt/nix
mount -o subvol=home,compress=zstd,noatime /dev/disk/by-label/nixos /mnt/home

# Label and mount EFI partition created by the Asahi installer
mkdir -p /mnt/boot
fatlabel /dev/disk/by-partuuid/`cat /proc/device-tree/chosen/asahi,efi-system-partition` EFI
mount /dev/disk/by-label/EFI /mnt/boot
```

Both `nixos-install` and `nixos-rebuild` have to be run with the `--impure` flag since vendor firmware from /boot/asahi has to be accessed. Using a folder inside the repo is not possible without git-adding the firmware so impure builds seem to be the most elegant solution.

When installing, setting TMPDIR to a subdirectory in /mnt is recommended to not run out of disk space.

Install the flake:

```bash
mkdir -p /mnt/tmp
TMPDIR=/mnt/tmp nixos-install --impure --flake /mnt/.nix#santisasahi
```

# Installing NixOS on the Razer Blade

This is intended for the Razer Blade 15 Advanced 2021 as a Windows dual-boot. Do the shrinking from Windows first, keep the existing EFI partition, and disable Windows Fast Startup before installing. If BitLocker is enabled, suspend it before changing partitions.

Boot the NixOS installer and create one Linux partition in the free space:

```bash
# Replace /dev/nvme0n1 and partition numbers with what lsblk shows.
lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL,MOUNTPOINTS
sgdisk /dev/nvme0n1 -n 0:0:0 -t 0:8300 -c 0:nixos
partprobe /dev/nvme0n1
lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL,MOUNTPOINTS

mkfs.btrfs -L nixos /dev/nvme0n1pX

mount /dev/disk/by-label/nixos /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/home
umount /mnt

mount -o subvol=root,compress=zstd,noatime /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/{nix,home,boot}
mount -o subvol=nix,compress=zstd,noatime /dev/disk/by-label/nixos /mnt/nix
mount -o subvol=home,compress=zstd,noatime /dev/disk/by-label/nixos /mnt/home
```

Mount the existing Windows EFI partition at `/mnt/boot`. If it does not already have the label `EFI`, either label it or update `hosts/razer/hardware-configuration.nix` after running `nixos-generate-config`.

```bash
mount /dev/disk/by-label/EFI /mnt/boot
```

Clone and install:

```bash
git clone https://github.com/santikid/dotnix /mnt/.nix
nixos-generate-config --root /mnt

# Optional but recommended: compare the generated file with hosts/razer/hardware-configuration.nix
# and copy over any device-specific module or filesystem changes.

nixos-install --flake /mnt/.nix#razer
```

The Razer profile keeps the same Niri desktop and `de`/`mac` keyboard layout as `santisasahi`, adds NVIDIA PRIME offload, Steam, GameMode, and OpenRazer. Launch Steam for CS2 with:

```bash
steam-nvidia
```
