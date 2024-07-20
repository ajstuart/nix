{ config, inputs, lib, pkgs, platform, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    #inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../_mixins/services/tailscale


    ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/0a1d56af-182c-45db-a63a-a02f4b796cac";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/E72D-232D";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/b50c965a-504b-40da-a6b4-b70f11c981c2"; }
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
    kernelPackages = lib.mkForce pkgs.linuxPackages_6_9;
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

    hardware.opengl = {
    enable = true;
    driSupport = true;
    #driSupport32Bit = true;
    extraPackages = with pkgs; [
      #intel-media-driver
      #intel-vaapi-driver
  #    vaapiVdpau
  #    libvdpau-va-gl
      #intel-compute-runtime
    ];
  };

    services = {
      udev.extraRules = ''
        # Remove NVIDIA Audio devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
      '';
       # Enable the X11 windowing system.
      xserver.enable = true;
      #xserver.videoDrivers = [ "nvidia" ];
      #xserver.videoDrivers = [ "intel" ];
      # mount usb drives to /media
      udisks2.enable = true;
      udisks2.mountOnMedia = true;
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
