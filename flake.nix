# flake.nix
{
        description = "Flake for Stunix machine configurations.";

        inputs = {
                nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
                # You can access packages and modules from different nixpkgs revs at the same time.
                # See 'unstable-packages' overlay in 'overlays/default.nix'.
                nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

                #disko.url = "github:nix-community/disko";
                #disko.inputs.nixpkgs.follows = "nixpkgs";

                #home-manager.url = "github:nix-community/home-manager/release-24.05";
                #home-manager.inputs.nixpkgs.follows = "nixpkgs";

                nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
                nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

                nixos-hardware.url = "github:NixOS/nixos-hardware/master";

                nixos-needtoreboot.url = github:thefossguy/nixos-needsreboot;
                nixos-needtoreboot.inputs.nixpkgs.follows = "nixpkgs";

                nix-index-database.url = "github:Mic92/nix-index-database";
                nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

                #sops-nix.url = "github:Mic92/sops-nix";
                #sops-nix.inputs.nixpkgs.follows = "nixpkgs";

                # FlakeHub
                #antsy-alien-attack-pico.url = "https://flakehub.com/f/wimpysworld/antsy-alien-attack-pico/*.tar.gz";
                #antsy-alien-attack-pico.inputs.nixpkgs.follows = "nixpkgs";

                #nix-snapd.url = "https://flakehub.com/f/io12/nix-snapd/0.1.*.tar.gz";
                #nix-snapd.inputs.nixpkgs.follows = "nixpkgs";

                fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";
                fh.inputs.nixpkgs.follows = "nixpkgs";
        };

        outputs =
            { self
            , nix-formatter-pack
            , nixpkgs
            , nixos-hardware
            , ...
            }@inputs:
            let
                inherit (self) outputs;
                # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
                stateVersion = "24.05";
                libx = import ./lib { inherit inputs outputs stateVersion; };
            in
            {
                nixosConfigurations = {
                    # Workstations
                    #  - sudo nixos-rebuild boot --flake $HOME/Zero/nix-config
                    #  - sudo nixos-rebuild switch --flake $HOME/Zero/nix-config
                    #  - nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel
                    milesobrien  = libx.mkHost { hostname = "milesobrien";  username = "stunix"; desktop = "pantheon"; };
                    picard   = libx.mkHost { hostname = "picard";   username = "stunix"; desktop = "pantheon"; };
                    laforge  = libx.mkHost { hostname = "laforge";  username = "stunix"; desktop = "plasma"; };

                };
            };
}
