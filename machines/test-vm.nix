{ ... }:

{
  imports = [
    ../modules/disko/zfs-root.nix
    ../modules/graphics/base.nix
    ../modules/packages/core.nix
    ../modules/audio.nix
    ../modules/boot.nix
    ../modules/locale.nix
    ../modules/networking.nix
    ../modules/services.nix
    ../modules/users.nix
  ];

  # Disk Setup
  diskSetup.device = "/dev/vda";

  networking.hostId = "a1b2c3d4";  # Needed for ZFS pool ownership

  # VM-specific config
  boot.initrd.kernelModules = [ "virtio_blk" "virtio_pci" ];
  boot.zfs.devNodes = "/dev/disk/by-uuid";  # Default `by-id` isn't populated in QEMU
}
