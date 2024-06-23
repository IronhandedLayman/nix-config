{
  description = "Initial nixos system flake based on Hokusai";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixvim, ...}: {
    homeConfigurations = {
      "ironhandedlayman" = home-manager.lib.homeManagerConfiguration {
        modules = [
          nixvim.homeManagerModules.nixvim
          ./ironhandedlayman-home.nix
        ];
      };
    };
    nixosConfigurations = {
      hokusai = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
