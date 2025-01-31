# WE SO BACK

# Installing on macOS

1. Install Xcode CLI Tools

`xcode-select --install`

2. Install Nix using the Determinate Systems installer

`curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`

4. Clone to ~/.nix and install

`git clone https://github.com/santikid/dotnix.git ~/.nix`

`nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.nix#<host>`

# Rectangle and Hyperkey

Manually set up hyperkey to capslock and set HYPER + (h,j,k,l,n,m) as hotkeys in rectangle

# Installing NixOS

Boot up nixos-minimal installer ISO

Optionally load different keymap (e.g. `loadkeys de`)

Format and mount disk to /mnt:

```
# using parted
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 1MiB 512MiB
parted /dev/sda -- mkpart primary 512MiB 100%
parted /dev/sda -- name 1 EFI
parted /dev/sda -- name 2 root
parted /dev/sda -- set 1 boot on

# using fdisk
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