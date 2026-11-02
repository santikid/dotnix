# dotnix

Personal Nix flake for macOS, NixOS, Linux containers, and Asahi NixOS hosts.

## Hosts

| Host | Platform | Role |
| --- | --- | --- |
| `santibook` | `aarch64-darwin` | macOS laptop |
| `opal` | `x86_64-linux` | NixOS host (Minisforum AI X1 Pro) |
| `jade` | `x86_64-linux` | Public VPS running ingress |
| `lime` | `x86_64-linux` | NixOS backup server |
| `ruby` | `x86_64-linux` | Incus VM |
| `razer` | `x86_64-linux` | Razer Blade laptop |
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

`make bootstrap` supplies the Opal and NixOS cache URLs and signing keys through `NIX_CONFIG`, replacing stale cache settings for that rebuild. Once that configuration is active, regular `make rebuild` invocations use the cache automatically.

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

Clone and install. When `opal` is reachable, supply the cache settings explicitly so the initial installation can reuse CI artifacts before the installed configuration takes effect:

```bash
git clone https://github.com/santikid/dotnix /mnt/.nix
nixos-install --flake /mnt/.nix#<machine> \
  --option extra-substituters http://opal:8180/dotnix \
  --option extra-trusted-public-keys 'dotnix:N7VDgNbJ+yj6YV97+97s5HrxQ38+27OSPm17BexG3qA='
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

The Razer profile keeps the same Niri desktop and `de`/`mac` keyboard layout as `santisasahi`, and adds NVIDIA support, Steam, GameMode, MangoHud, and OpenRazer. Launch Steam normally:

```bash
steam
```

Set CS2's Steam launch options once so GameMode and MangoHud apply to the game rather than the Steam client:

```text
MANGOHUD=1 gamemoderun %command%
```

## Drift From `main`

`razer` is a long-lived branch: `main` is merged into it, never the other way round. Last synced with `main` at `2616eba` (2026-11-02).

Razer-only, by design:

- `hosts/razer/` (host config, hardware config, `razer-performance.c`), the `razer` entry in `flake.nix`, and the `razer` line in `make check`.
- The razer section of this README and the `/docs/` entry in `.gitignore`.

Shared modules that differ from `main` (these also change `santisasahi` when it is built from this branch):

- `modules/linux/desktop/niri/default.nix`: tuigreet replaces regreet as the greeter, the `de`/`mac` layout is set through `services.xserver.xkb` with `console.useXkbConfig`, `bibata-cursors` is installed system-wide, and Niri manages `xwayland-satellite` itself instead of spawning it at startup.
- `modules/linux/desktop/niri/lib/scripts.nix`: the `xwaylandSatellite` command is gone, matching the above.
- `modules/linux/desktop/niri/lib/binds.nix`: `Mod+E` cycles preset column widths (same key as paneru's `cmd - e` on macOS), and `Mod+R` / `Mod+Shift+R` are unbound. `main` still uses `Mod+R` / `Mod+Shift+R`.

Expected to go stale:

- `flake.lock`: automated input updates land on `main` only. After a merge, take `main`'s lock (`git checkout --theirs flake.lock` while merging into `razer`), then run `nix flake lock`. This only adds inputs if `razer` ever gains some of its own.
- Shared modules not listed above (`modules/home.nix`, `modules/packages.nix`, `modules/dev-tools`, `modules/coding-agents.nix`, the nvim config) are identical to `main` at the last sync and only pick up changes when `main` is merged again.
