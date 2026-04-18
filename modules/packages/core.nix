{ pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    gammastep
    git
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

    preferences = {
      "browser.newtabpage.activity-stream.showWeather" = false;
    };

    policies = {
      # Feature Disabling
      DisableFirefoxStudies         = true;
      DisableFirefoxAccounts        = true;
      DisableFirefoxScreenshots     = true;
      DisableForgetButton           = true;
      DisableMasterPasswordCreation = true;
      DisableProfileImport          = true;
      DisableProfileRefresh         = true;
      DisableSetDesktopBackground   = true;
      DisablePocket                 = true;
      DisableTelemetry              = true;
      DisableFormHistory            = true;
      DisablePasswordReveal         = true;

      # UI and Behavior
      DisplayBookmarksToolbar = "never";
      DisplayMenuBar = "never";
      OfferToSaveLogins = false;

      DNSOverHTTPS = {
        Enabled = false;
        Locked = true;
      };

      # Extensions
      ExtensionSettings = let
        mozilla = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
      in {
        "*".installation_mode = "blocked";

        "uBlock0@raymondhill.net" = {
          install_url = mozilla "ublock-origin";
          installation_mode = "force_installed";
          private_browsing = true;
        };

        "addon@darkreader.org" = {
          install_url = mozilla "darkreader";
          installation_mode = "force_installed";
        };

        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = mozilla "bitwarden-password-manager";
          installation_mode = "force_installed";
        };

        "jid1-Y3WfE7td45aWDw@jetpack" = {
          install_url = mozilla "behind_the_overlay";
          installation_mode = "force_installed";
        };

        "jid1-KKzOGWgsW3Ao4Q@jetpack" = {
          install_url = mozilla "i-dont-care-about-cookies";
          installation_mode = "force_installed";
        };

        "enhancerforyoutube@maximerf.addons.mozilla.org" = {
          install_url = mozilla "enhancer-for-youtube";
          installation_mode = "force_installed";
        };
      };

      FirefoxHome = {
        Search = true;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        Stories = false;
        SponsoredPocket = false;
        SponsoredStories = false;
        Snippets = false;
        Locked = true;
      };

      Preferences = {
        # Force the built-in dark color scheme
        "extensions.activeThemeID" = { Value = "firefox-compact-dark@mozilla.org"; Status = "locked"; };
      };

      SearchEngines = {
        Default = "DuckDuckGo";
        Remove = ["Google" "Bing" "eBay" "Wikipedia (en)" "Perplexity" ];
      };
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
    histSize = 10000;

    promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    '';
  };
  environment.shells = with pkgs; [ zsh ];  # Configures /etc/shells

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}
