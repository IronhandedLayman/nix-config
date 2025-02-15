{
  description = "Initial nixos system flake based on Hokusai";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nixpkgs-stable = {
      url = "github:NixOS/nixpkgs/nixos-24.05";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vivepro2Driver = {
      url = "github:CertainLach/VivePro2-Linux-Driver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
#    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager, nixvim, vivepro2Driver, ...}: 
    let 
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs;
      pkgs-stable = import nixpkgs-stable { inherit system; config.allowUnfree = true; };
      username = "ironhandedlayman";
      hostname = "hokusai";
    in {
      nixosConfigurations = {
        ${hostname} = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
#          vivepro2Driver.driver-proxy-release
              home-manager.nixosModules.home-manager {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.sharedModules = [
                  nixvim.homeManagerModules.nixvim
                ];
                home-manager.extraSpecialArgs = {
                  inherit username;
                  inherit hostname;
                  inherit pkgs-stable;
#                  inherit hyprland;
                };
                home-manager.users.${username} = import ./ironhandedlayman-home.nix;
              }
          ];
          specialArgs = {
            inherit username;
            inherit hostname;
            inherit pkgs-stable;
#            inherit hyprland;
          };
        };
      };
    };
}
