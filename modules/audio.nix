{ ... }:

{
  # Enable Pipewire and all 3 compatibility servers
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Allow soft realtime (audio server needs this)
  security.rtkit.enable = true;
}
