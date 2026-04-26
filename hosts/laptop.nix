{ ... }:

{
  imports = [
    ../modules/common.nix
    ../modules/disko/zfs-root.nix
    ../modules/graphics/base.nix
    ../modules/packages/core.nix
    ../modules/packages/dev.nix
    ../modules/audio.nix
    ../modules/boot.nix
    ../modules/locale.nix
    ../modules/networking.nix
    ../modules/services.nix
    ../modules/users.nix
  ];

  # Set system state version
  system.stateVersion = "25.11";

  # Disk Setup
  diskSetup.device = "/dev/disk/by-path/pci-0000:00:0e.0-pci-10000:e1:00.0-nvme-1";
  networking.hostId = "e12c75ea";  # Needed for ZFS pool ownership
}
