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

  # Set system state version
  system.stateVersion = "25.05";

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Disk Setup
  diskSetup.device = "/dev/vda";
  boot.zfs.devNodes = "/dev/disk/by-path";  # Required for QEMU VMs
  networking.hostId = "d34dc0d3";  # Needed for ZFS pool ownership
}
