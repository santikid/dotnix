# dotnix

Personal Nix flake for macOS, NixOS, Linux containers, and Asahi NixOS hosts.

## Hosts

| Host | Platform | Role |
| --- | --- | --- |
| `santibook` | `aarch64-darwin` | macOS desktop |
| `lisbon` | `aarch64-darwin` | macOS server |
| `obsidian` | `x86_64-linux` | NixOS server |
| `ruby` | `x86_64-linux` | Incus VM |
| `santisasahi` | `aarch64-linux` | Asahi NixOS laptop |

## Maintenance

```bash
make format
make check
make bootstrap
make rebuild
make update
make upgrade
make rekey
```

`make bootstrap` performs the first rebuild with the Attic substituter supplied explicitly. Once that configuration is active, regular `make rebuild` invocations use the cache automatically.

`santisasahi` rebuilds use `--impure` because the Apple Silicon firmware lives outside the flake.

## Installing On macOS

1. Install Xcode CLI tools.

   ```bash
   xcode-select --install
   ```

2. Install Nix using the Lix installer.

   ```bash
   curl -sSf -L https://install.lix.systems/lix | sh -s -- install
   ```

3. Clone this flake.

   ```bash
   git clone https://github.com/santikid/dotnix.git ~/.nix
   ```

4. Switch to the host configuration.

   ```bash
   nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.nix#<host>
   ```

## Installing NixOS

Boot the NixOS minimal installer ISO, optionally load a keymap such as `loadkeys de`, then format and mount the disk:

```bash
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 1MiB 512MiB
parted /dev/sda -- mkpart primary 512MiB 100%
parted /dev/sda -- name 1 EFI
parted /dev/sda -- name 2 root
parted /dev/sda -- set 1 boot on

mkfs.fat -F 32 /dev/sda1
mkfs.ext4 /dev/sda2

mount /dev/disk/by-partlabel/root /mnt
mkdir /mnt/boot
mount /dev/disk/by-partlabel/EFI /mnt/boot
```

For a new host, generate hardware config:

```bash
nixos-generate-config --root /mnt
```

Clone and install. When `obsidian` is reachable, supply the cache settings explicitly so the initial installation can reuse CI artifacts before the installed configuration takes effect:

```bash
git clone https://github.com/santikid/dotnix /mnt/.nix
nixos-install --flake /mnt/.nix#<machine> \
  --option extra-substituters http://obsidian:8180/dotnix \
  --option extra-trusted-public-keys 'dotnix:l60JA9kCmi7QH4e9UONJagnC7aqyJkJc++qsiKCYU6M='
```

## Installing Asahi NixOS

Asahi installation follows the `nix-community/nixos-apple-silicon` partitioning flow. Create and mount the root subvolumes:

```bash
sgdisk /dev/nvme0n1 -n 0:0 -s
sgdisk /dev/nvme0n1 -p
mkfs.btrfs -L nixos /dev/nvme0n1p5

mount /dev/disk/by-label/nixos /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/home
umount /mnt

mount -o subvol=root,compress=zstd,noatime /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/{nix,home,boot}
mount -o subvol=nix,compress=zstd,noatime /dev/disk/by-label/nixos /mnt/nix
mount -o subvol=home,compress=zstd,noatime /dev/disk/by-label/nixos /mnt/home

fatlabel /dev/disk/by-partuuid/`cat /proc/device-tree/chosen/asahi,efi-system-partition` EFI
mount /dev/disk/by-label/EFI /mnt/boot
```

Install with an impurity allowance for host-local firmware:

```bash
mkdir -p /mnt/tmp
TMPDIR=/mnt/tmp nixos-install --impure --flake /mnt/.nix#santisasahi
```
