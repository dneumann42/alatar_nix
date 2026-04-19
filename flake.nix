{
  description = "NixOS configuration for alatar systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      mkHost = hostModule:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { hardwareConfig = ./hardware-configuration.nix; };
          modules = [
            ./configuration.nix
            hostModule
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.dneumann = import ./home.nix;
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        desktop = mkHost ./hosts/desktop-nvidia.nix;
        desktop-nvidia = mkHost ./hosts/desktop-nvidia.nix;
        laptop = mkHost ./hosts/laptop.nix;
      };
    };
}
