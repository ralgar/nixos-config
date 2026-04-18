{ ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable nix subcommands and flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Increase memory size for test VMs (default 1024)
  virtualisation.vmVariantWithDisko.virtualisation.memorySize = 4096;
}
