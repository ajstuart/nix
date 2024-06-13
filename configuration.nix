# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, inputs, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #/home/stunix/build/musnix
      #/home/stunix/portainer-on-nixos
      #<nixos-hardware/common/gpu/nvidia>
      #inputs.nixos-hardware.nixosModules.common-gpu-nvidia
      #inputs.nixos-hardware.nixosModules.common-cpu-intel
      #<nixos-hardware/common/gpu/intel>
      #<nixos-hardware/common/cpu/intel>
      #inputs.nixos-hardware.nixosModules.common-gpu-intel
      #inputs.nixos-hardware.nixosModules.common-cpu-intel
      #inputs.nixos-hardware.nixosModules.common-hidpi
    ];

  boot = {
    # HP Z2 Mini Gen5 Setup for Nvidia as "nvenc" and intel igpu as primary.
    # We blacklist all of nvidia things
    blacklistedKernelModules = lib.mkDefault [ "nouveau" ];
    #blacklistedKernelModules = lib.mkDefault [ "nouveau" "nvidia_drm" "nvidia_modeset" "nvidia"];
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "uas" "usb_storage" "sd_mod"];
    initrd.systemd.enable = true;
    kernelModules = [ "kvm-intel" "sg" "uinput" "nvidia" ];
    #initrd.kernelModules = [ "nvidia" ];
    # This seems to nee to be here??  Will test further 6/6/24 - AJS
    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  };

  hardware = {
    nvidia = {
      prime = {
        offload= {
          enable = false;
          #enableOffloadCmd = true;
        };
        # get our intel busID
        intelBusId = "PCI:0:2:0";
        # Get our Nvidia BusID
        nvidiaBusId = "PCI:1:0:0";
        # Make the Intel iGP Default.  Nvidia is for Cuda/NVENC
        #reverseSync.enable = true;
        #sync.enable = true;
        #allowExternalGpu = false;
      };
      nvidiaSettings = true;
      modesetting.enable = false;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
    };
  };
    # This is for Intel Hardware Acceleration Testing.
#  nixpkgs.config.packageOverrides = pkgs: {
#    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
#  };
 # boot.kernelParams = [
    #"i915.enable_guc=2"
    #"i915.force_probe=9bc5"
  #];
  #nixpkgs.config.packageOverrides = pkgs: {
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "milesobrien"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable Blueteeth
  #hardware.bluetooth.enable = true;
  #hardware.bluetooth.powerOnBoot = true;


  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  #services.xserver.videoDrivers = [ "intel" ];

  # mount usb drives to /media
  services.udisks2.enable = true;
  services.udisks2.mountOnMedia = true;

  # Enable the KDE Plasma  Desktop Environment.
  services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true;
  # Plasma 5 stuff for 23.11 nixos.  Updated 6/1/24
  #services.xserver.desktopManager.plasma5.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.dconf.enable = true;



  # Enable PolKit
  security.polkit.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  #services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
    wireplumber.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;



  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.stunix = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "stunix";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "libvirtd" "video" "render" "audio" "input" ];
    packages = with pkgs; [
    #  thunderbird
      gnome.gnome-software
    ];
  };

   # Enable virtualisation

  #virtualisation.libvirtd.enable = true;
  #programs.virt-manager.enable = true;


  # Lets get Fish Shell - CF 6-1-22

  programs.fish.enable = true;

  # Trying to get ADB for Android 11-23.22

  #programs.adb.enable = true;

  #virtualisation.docker.enable=true;

  # Flatpak bitches - CF 6-1-22

  services.flatpak.enable = true;
  xdg.portal.enable = true;
  # Enable Vulkan
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      #intel-media-driver
      #intel-vaapi-driver
  #    vaapiVdpau
  #    libvdpau-va-gl
      #intel-compute-runtime
    ];
  };

  hardware.opengl.driSupport = true;
  # For 32 bit applications
  hardware.opengl.driSupport32Bit = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  # Enable Nix experimental features and Flakes 4-17-24

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
     #nvidia-offload
     vim
     libsForQt5.ktexteditor
     pkgs.nvidia-vaapi-driver
     #kate
     htop
     nixFlakes
     pkgs.tailscale
     btop
     htop
     btrfs-progs
     btrfs-snap
     pciutils   
     pkgs.cifs-utils
     pkgs.samba
     nmap
     #mosh
     #ark
     fuse
     appimage-run
     #android-udev-rules
     #adb-sync
     git
     #jmtpfs
     gnumake
     unzip
     zip
     gnupg
     pkgs.restic
     pkgs.autorestic
     pkgs.restique
     #pkgs.nextcloud-client
     #google-chrome
     quickemu
     quickgui
     junction
     distrobox
     tor-browser
     v4l-utils
     v4l2-relayd
     libv4l
     sunshine
     ltunify
     gtop
     #ventoy
     #wine-wayland
     #winetricks
     #wineasio
     #bottles-unwrapped
     yarn
     #cool-retro-term
     #wayland-protocols
     #wayland-scanner
     #wayland
     avahi
     mesa
     libffi
     libevdev
     libcap
     libdrm
     xorg.libXrandr
     xorg.libxcb
     ffmpeg-full
     libevdev
     libpulseaudio
     xorg.libX11
     pkgs.xorg.libxcb
     xorg.libXfixes
     libva
     libvdpau
     pkgs.moonlight-qt
     pkgs.sunshine
     firefox
     #slack
     #telegram-desktop
     nheko
     libsForQt5.neochat
     #element-desktop-wayland
     mpv
     haruna
     trayscale
     #reaper
     lame
     xdotool
     pwvucontrol
     easyeffects
     pipecontrol
     wireplumber
     pavucontrol
     ncpamixer
     carla
     qjackctl
     qpwgraph
     #libsForQt5.plasma-browser-integration
     sonobus
     vlc
     typora
     neovim
     vimPlugins.LazyVim
     #pkgs.wayland-utils
     pkgs.vulkan-tools
     #pkgs.amdvlk
     #pkgs.driversi686Linux.amdvlk
     pkgs.clinfo
     #element-desktop
     gh
     gitui
     cmake
     ispell
     gcc
     go
     aspell
     gnumake
     patchelf
     alacritty
     glxinfo
     libnotify
     #yt-dlp
     binutils
     dstat
     file
     iotop
     pciutils
     zellij
     tree
     lsof
     lshw
     #pkgs.gpustat
     jellyfin-ffmpeg
     pkgs.makemkv
     #pkgs.streamdeck-ui
     pkgs.alsa-scarlett-gui
     #beta-davinci-resolve
     #pkgs.davinci-resolve-studio
     #jellyfin-web
     #pkgs.globalprotect-openconnect
     #pkgs.openconnect
     #pkgs.gp-saml-gui
     pkgs.audiobookshelf
     pkgs.delfin
     pkgs.kdePackages.kdeconnect-kde
     pkgs.sunshine
     pkgs.moonlight-qt
     #pkgs.docker-compose
     pkgs.nvtopPackages.full
     #pkgs.filebot
       ];

  #pkgs.dockerTools.pullImage{
   # imageName = "portainer/portainer-ce";
   # finaleImageTag = "newest" 
  #};

  # Wayland support for Slack
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable Auto Optimising the store CF 5-18-23
  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

  # Passwords are for Losers
    security = {
    sudo.wheelNeedsPassword = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
   services.openssh.enable = true;

  # Enable Tailscale Service - CF 6-3-22
   services.tailscale.enable = true;
   services.audiobookshelf = {
     enable = true;
     host = "0.0.0.0";
     port = 8000;
  };
  # JellyFin
   services.jellyfin = {
     enable = true;
     openFirewall = true;
     user="stunix";
  };
  security.wrappers.sunshine = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+p";
    source = "${pkgs.sunshine}/bin/sunshine";
  };
  # Needed for network discovery
  services.avahi.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  services.udev.packages = [ pkgs.sunshine ];

  # Enable musnix
  #musnix.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
   networking.firewall.enable = false;

   # copy our current configuration.nix at /run/current-system/configuration.nix
   #system.copySystemConfiguration = true;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
