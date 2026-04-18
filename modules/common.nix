{ config, lib, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable nix subcommands and flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
