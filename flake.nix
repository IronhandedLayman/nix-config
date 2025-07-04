{
  description = "Initial nixos system flake based on Hokusai";


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
    vivepro2Driver = {
      url = "github:CertainLach/VivePro2-Linux-Driver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs = inputs@{ self, hyprland, nixpkgs, nixpkgs-stable, home-manager, nixvim, vivepro2Driver, nix-darwin, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-stable = nixpkgs-stable.legacyPackages.${system};
      username = "ironhandedlayman";
      hostname = "hokusai";
    in
    {
      darwinConfigurations."kataribe" = nix-darwin.lib.darwinSystem {
        modules = [ ./kataribe-configuration.nix ];
      };
      nixosConfigurations = {
        ${hostname} = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [
                nixvim.homeManagerModules.nixvim
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
