{ pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    gammastep
    grim
    hypridle
    hyprlock
    hyprpaper
    jq
    libfido2
    libnotify
    mako
    mpd
    slurp
    waybar
    wl-clipboard
    wlr-randr
    wofi
    yadm
    zsh-powerlevel10k
  ];

  programs.firefox = {
    enable = true;

    policies = {
      # Install uBlock Origin
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
      };

      # Force the built-in dark color scheme
      DisplayMenuBar = "default-off";
      Preferences = {
        "extensions.activeThemeID" = {
          Value = "firefox-compact-dark@mozilla.org";
          Status = "locked";  # Or "default" to allow users to override
        };
      };
    };

    # Native vertical tabs (requires Firefox 135+)
    preferences = {
      "sidebar.revamp" = true;
      "sidebar.verticalTabs" = true;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.hyprland.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}
