{ ... }:

{
  # Bootloader config
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use systemd-based initrd instead of Busybox (works better with encryption)
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;   # Toggle shell on emergency/failure

  # Explicitly define kernel version (defaults to LTS).
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.kernelPackages = pkgs.linuxPackages_6_17;
}
