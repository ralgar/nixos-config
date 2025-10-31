{ lib, ... }:

{
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable NTP
  services.timesyncd.enable = lib.mkDefault true;
}
