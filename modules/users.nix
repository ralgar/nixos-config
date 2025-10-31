{ pkgs, ... }:

{
  # Define a user account. Don't forget to change the password with ‘passwd’.
  users.users.ralgar = {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };
}
