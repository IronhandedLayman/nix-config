{
  description = "Initial nixos system flake based on Hokusai";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nixpkgs-stable = {
      url = "github:NixOS/nixpkgs/nixos-26.05";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
#      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
#    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
  };

  outputs = inputs@{ nixpkgs, nixpkgs-stable, home-manager, nixvim, sops-nix, ...}: 
    let 
      system = "x86_64-linux";
      pkgs-stable = import nixpkgs-stable { inherit system; config.allowUnfree = true; config.cudaSupport = true; };
      username = "ironhandedlayman";
      hostname = "hokusai";
    in {
      # Bespoke packages from ./packages, exposed so `nix build .#sonar` works
      # and nix-update can bump them (see update-packages.sh).
      packages.${system} = import ./packages {
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      };

      nixosConfigurations = {
        ${hostname} = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            sops-nix.nixosModules.sops
              home-manager.nixosModules.home-manager {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.sharedModules = [
                  nixvim.homeModules.nixvim
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
