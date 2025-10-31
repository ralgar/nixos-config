{ config, pkgs, modulesPath, dotfiles, ... }:

let
  installScript = pkgs.writeShellScriptBin "install-nixos" (builtins.readFile ../files/install-nixos.sh);
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../modules/packages/core.nix
    ../modules/graphics/base.nix
    ../modules/audio.nix
  ];

  # Set system state version
  system.stateVersion = "25.05";

  # Enable flakes in the ISO
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Make the ISO bootable
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  # Auto-login for convenience
  services.getty.autologinUser = "nixos";

  # Set the `nixos` user's shell
  users.users.nixos.shell = pkgs.zsh;

  # Copy dotfiles into the nixos user's home
  system.activationScripts.installDotfiles = ''
    mkdir -p /home/nixos
    shopt -s dotglob
    cp -r ${dotfiles}/* /home/nixos/
    chown -R nixos:users /home/nixos
  '';

  # Copy the config files into the ISO at /etc/nixos, respecting .gitignore
  environment.etc."nixos".source = pkgs.nix-gitignore.gitignoreSource [] ../.;


  # Install packages
  environment.systemPackages = with pkgs; [
    disko
    installScript
  ];
}
