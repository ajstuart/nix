{ config, desktop, hostname, inputs, lib, pkgs, platform, username, ... }:
let
  isWorkstation = if (desktop != null) then true else false;
  isStreamstation = if (hostname == "laforge" || hostname == "vader") && (isWorkstation) then true else false;
in
{
  boot = lib.mkIf (isStreamstation) {
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=13 card_label="OBS Virtual Camera" exclusive_caps=1
    '';
  };

  environment = {
    # Desktop environment applications/features I don't use or want
    gnome.excludePackages = with pkgs; [
      baobab
      gnome-console
      gnome-text-editor
      gnome.epiphany
      gnome.geary
      gnome.gnome-music
      gnome.gnome-system-monitor
      gnome.totem
    ];

    mate.excludePackages = with pkgs; [
      mate.caja-dropbox
      mate.eom
      mate.mate-themes
      mate.mate-netbook
      mate.mate-icon-theme
      mate.mate-backgrounds
      mate.mate-icon-theme-faenza
    ];

    pantheon.excludePackages = with pkgs; [
      pantheon.elementary-code
      pantheon.elementary-music
      pantheon.elementary-photos
      pantheon.elementary-videos
      pantheon.epiphany
    ];

    systemPackages = (with pkgs; [
      _1password
      lastpass-cli
    ] ++ lib.optionals (isWorkstation) [
      _1password-gui
      brave
      chromium
      celluloid
      element-desktop
      fractal
      gimp-with-plugins
      gnome.dconf-editor
      gnome.gnome-sound-recorder
      google-chrome
      halloy
      inkscape
      libreofficeterm  
      meld
      #microsoft-edge
      #opera
      #pika-backup
      #tartube
      #tenacity
      usbimager
      vivaldi
      vivaldi-ffmpeg-codecs
      #wavebox
      #yaru-theme
      #zoom-us
      pkgs.tailscale
      trayscale
    ] ++ lib.optionals (isWorkstation && (desktop == "gnome" || desktop == "pantheon")) [
      loupe
      marker
    ] ++ lib.optionals (isWorkstation && (desktop == "mate" || desktop == "pantheon")) [
      tilix
    ] ++ lib.optionals (isWorkstation && desktop == "gnome") [
      blackbox-terminal
      gnome-extension-manager
      gnomeExtensions.start-overlay-in-application-view
      gnomeExtensions.tiling-assistant
      gnomeExtensions.vitals
    ])
     ++ (with pkgs; lib.optionals (isStreamstation) [
      # https://nixos.wiki/wiki/OBS_Studio
      blackbox-terminal
      rhythmbox
    ]);
  };

  programs = {
    chromium = lib.mkIf (isWorkstation) {
      extensions = [
        #"hdokiejnpimakedhajhdlcegeplioahd" # LastPass
        #"kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly
        #"cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        #"mdjildafknihdffpkfmmpnpoiajfjnjd" # Consent-O-Matic
        #"mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube
        #"gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
        #"fdpohaocaechififmbbbbbknoalclacl" # GoFullPage
        "clpapnmmlmecieknddelobgikompchkk" # Disable Automatic Gain Control
        #"cdglnehniifkbagbbombnjghhcihifij" # Kagi
      ];
    };
    dconf.profiles.user.databases = [{
      settings = with lib.gvariant; lib.mkIf (isWorkstation) {
      };
    }];
  };


  #systemd.tmpfiles.rules = [
  #  "d /mnt/snapshot/${username} 0755 ${username} users"
 # ];
}
