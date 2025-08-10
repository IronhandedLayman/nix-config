{
  description = "Builds all ironhandedlayman systems the Nix way";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nixpkgs-stable = {
      url = "github:NixOS/nixpkgs/nixos-25.05";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager, nixvim, nix-darwin, ... }:
    let
      username = "ironhandedlayman";
    in
    {
      inherit username;
      darwinConfigurations =
        let
          hostname = "kataribe";
          system = "aarch64-darwin";
          pkgs = nixpkgs.legacyPackages.${system};
          pkgs-stable = nixpkgs-stable.legacyPackages.${system};
        in
        {
          ${hostname} = nix-darwin.lib.darwinSystem {
            modules = [
              ./kataribe-configuration.nix
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.sharedModules = [
                  nixvim.homeModules.nixvim
                ];
                home-manager.extraSpecialArgs = {
                  inherit username hostname pkgs-stable system;
                };
                home-manager.users.${username} = import ./ironhandedlayman-home.nix;
              }
            ];
            specialArgs = { inherit inputs pkgs pkgs-stable username hostname system; };
          };
        };
      nixosConfigurations =
        let
          hostname = "hokusai";
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.${system};
          pkgs-stable = nixpkgs-stable.legacyPackages.${system};
        in
        {
          ${hostname} = nixpkgs.lib.nixosSystem {
            inherit system pkgs pkgs-stable hostname;
            modules = [
              ./configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.sharedModules = [
                  nixvim.homeModules.nixvim
                ];
                home-manager.extraSpecialArgs = {
                  inherit username;
                  inherit hostname;
                  inherit pkgs-stable;
                };
                home-manager.users.${username} = import ./ironhandedlayman-home.nix;
              }
            ];
            specialArgs = {
              inherit username;
              inherit hostname;
              inherit pkgs-stable;
            };
          };
        };
    };
}
