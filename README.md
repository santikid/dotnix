# WE SO BACK

# Installing on macOS

1. Install Xcode CLI Tools

`xcode-select --install`

2. Install Nix using the Determinate Systems installer

`curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`

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

Installing an Asahi system is similar to regular NixOS, but the formatting has to be done as explained in `tpwrules/apple-silicon-support`. 

```bash
# Create root partition
sgdisk /dev/nvme0n1 -n 0:0 -s

# Get number of root partition (code 8300), usually 5
sgdisk /dev/nvme0n1 -p

# Format root partition
mkfs.ext4 -L nixos-root /dev/nvme0n1p5

# Mount partitions
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-partuuid/`cat /proc/device-tree/chosen/asahi,efi-system-partition` /mnt/boot
```

The EFI partition can be renamed with `fatlabel /dev/nvme0n1pX EFI` so it can be mounted through /dev/disk/by-label/EFI (both during install and in `hardware-configuration.nix`).

```bash
fatlabel /dev/disk/by-partuuid/`cat /proc/device-tree/chosen/asahi,efi-system-partition` EFI
```

The files `all_firmware.tar.gz` and `kernelcache*` from `(/mnt/)/boot/asahi` have to be copied to hosts/(machine)/firmware before running `nixos-install`.