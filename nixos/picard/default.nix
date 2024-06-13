{ config, inputs, lib, pkgs, platform, ... }:

{
  imports = [
    #inputs.nixos-hardware.nixosModules.common-cpu-amd
    #inputs.nixos-hardware.nixosModules.common-gpu-amd
    #inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.microsoft-surface-common
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


  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];





    services = {
      #udev.extraRules = ''
        # Remove NVIDIA Audio devices, if present
       # ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", #ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
      #'';
       # Enable the X11 windowing system.
      xserver.enable = true;
      #xserver.videoDrivers = [ "nvidia" ];
      #xserver.videoDrivers = [ "intel" ];
      # mount usb drives to /media
      #udisks2.enable = true;
      #udisks2.mountOnMedia = true;
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
