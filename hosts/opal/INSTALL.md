# Installing Opal

Opal uses both internal NVMe drives as one Btrfs RAID1 filesystem. Data and
metadata are mirrored, providing roughly 1 TB usable capacity. Each disk also
has its own EFI system partition so either disk can boot independently.

The commands below destroy both selected disks. Boot the NixOS minimal ISO,
become root, and identify the two internal drives first:

```bash
lsblk -d -o NAME,SIZE,MODEL,SERIAL
nvme list
```

Set these to the stable `/dev/disk/by-id` names reported for the internal
drives. Do not use the example values unchanged.

```bash
export OPAL_DISK_A=/dev/disk/by-id/nvme-REPLACE_WITH_FIRST_DRIVE
export OPAL_DISK_B=/dev/disk/by-id/nvme-REPLACE_WITH_SECOND_DRIVE

lsblk -d -o NAME,SIZE,MODEL,SERIAL "$OPAL_DISK_A" "$OPAL_DISK_B"
```

Partition both disks with a 1 GiB EFI partition and a Btrfs data partition:

```bash
for disk in "$OPAL_DISK_A" "$OPAL_DISK_B"; do
  sgdisk --zap-all "$disk"
  sgdisk --new=1:1MiB:+1GiB --typecode=1:EF00 "$disk"
  sgdisk --new=2:0:0 --typecode=2:8300 "$disk"
done

partprobe "$OPAL_DISK_A"
partprobe "$OPAL_DISK_B"
udevadm settle
```

Resolve the stable partition paths, create the two EFI filesystems, and create
the mirrored Btrfs filesystem:

```bash
export OPAL_ESP_A="${OPAL_DISK_A}-part1"
export OPAL_ESP_B="${OPAL_DISK_B}-part1"
export OPAL_DATA_A="${OPAL_DISK_A}-part2"
export OPAL_DATA_B="${OPAL_DISK_B}-part2"

mkfs.fat -F 32 -n OPAL-ESP-A "$OPAL_ESP_A"
mkfs.fat -F 32 -n OPAL-ESP-B "$OPAL_ESP_B"
mkfs.btrfs -f -L opal -d raid1 -m raid1 "$OPAL_DATA_A" "$OPAL_DATA_B"
```

Create and mount the subvolumes expected by the host configuration:

```bash
mount /dev/disk/by-label/opal /mnt
for subvolume in root nix home srv; do
  btrfs subvolume create "/mnt/$subvolume"
done
umount /mnt

mount -o subvol=root,compress=zstd,noatime,discard=async /dev/disk/by-label/opal /mnt
mkdir -p /mnt/{nix,home,srv,boot-a,boot-b}
mount -o subvol=nix,compress=zstd,noatime,discard=async /dev/disk/by-label/opal /mnt/nix
mount -o subvol=home,compress=zstd,noatime,discard=async /dev/disk/by-label/opal /mnt/home
mount -o subvol=srv,compress=zstd,noatime,discard=async /dev/disk/by-label/opal /mnt/srv
mount /dev/disk/by-label/OPAL-ESP-A /mnt/boot-a
mount /dev/disk/by-label/OPAL-ESP-B /mnt/boot-b
```

Generate a temporary hardware configuration and compare its detected kernel
modules with `hosts/opal/hardware-configuration.nix`. The flake file remains the
source of truth for filesystems because it mounts the multi-device Btrfs
filesystem by label and gives both EFI partitions stable labels.

```bash
nixos-generate-config --root /mnt --show-hardware-config
```

Clone and install:

```bash
git clone https://github.com/santikid/dotnix /mnt/.nix
nixos-install --flake /mnt/.nix#opal \
  --option extra-substituters http://obsidian:8180/dotnix \
  --option extra-trusted-public-keys 'dotnix:l60JA9kCmi7QH4e9UONJagnC7aqyJkJc++qsiKCYU6M='
```

After rebooting, verify that Btrfs is using RAID1 for both data and metadata and
that both boot partitions contain GRUB:

```bash
sudo btrfs filesystem usage /
findmnt /boot-a /boot-b
sudo smartctl --scan-open
```

The external OWC 4M2 and ZFS are intentionally not configured yet. Add them
only after the enclosure is attached and its stable device IDs and desired pool
topology are known.
