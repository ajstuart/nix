{ config, inputs, lib, pkgs, platform, ... }:

{
  imports = [
    #inputs.nixos-hardware.nixosModules.common-cpu-amd
    #inputs.nixos-hardware.nixosModules.common-gpu-amd
    #inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    #inputs.nixos-hardware.nixosModules.microsoft-surface-common
    inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
    ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/0f7f1c8c-2b52-43d4-9d6a-ff77ee002336";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/323B-1EC4";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };


  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "surface_aggregator_hub" "surface_aggregator_registry" "8250_dw" "intel_lpss" "intel_lpss" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "hid-microsoft"];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "i915.enable_rc6=1" "i915.enable_psr=0" "systemd.unified_cgroup_hierarchy=0" ];
  #boot.kernelPatches = [ "surface" "hibernate-progress" ];
  sound.enable = true;

    services = {
      #udev.extraRules = ''
        # Remove NVIDIA Audio devices, if present
       # ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", #ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
      #'';
       # Enable the X11 windowing system.
      xserver.enable = true;
      iptsd.config.Touch.DisableOnPalm = true;
      iptsd.config.Touch.DisableOnStylus = true;
      iptsd.config.Touch.Overshoot = 0.5;
      iptsd.config.Contacts.Neutral = "Average";
      iptsd.config.Contacts.NeutralValue = 100;
      autorandr.enable = true;
      fwupd.enable = true;
      #xserver.upscaleDefaultCursor = true;
      usbmuxd = { enable = true; };
      #xserver.videoDrivers = [ "nvidia" ];
      #xserver.videoDrivers = [ "intel" ];
      # mount usb drives to /media
      #udisks2.enable = true;
      #udisks2.mountOnMedia = true;
  };
  powerManagement.enable = true;
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  #hardware.pulseaudio.enable = true;
}
