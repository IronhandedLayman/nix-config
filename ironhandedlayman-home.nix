{ config, pkgs, lib, ... }:
let 
  username="ironhandedlayman";
in {

  imports = [
    ./neovim.nix          # imports nixvim settings
    ./shell.nix           # general shell preferences
    ./windowmanager.nix   # preferred window manager settings, terminal, and keyboard bindings
  ]; 

  home = {
    stateVersion = "23.11"; 

    username = "${username}";
    homeDirectory = "/home/${username}";

    packages = with pkgs; [
      nvd
      protonup
      wlr-randr
    ];

    file = {
    };
  
    sessionVariables = {
      EDITOR = lib.mkForce "nvim";
      DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
    };
  };

  programs.git = {
    enable = true;
    userName = "ironhandedlayman";
    userEmail = "leadhyena@gmail.com";
    extraConfig = {
      init.defaultBranch = "main"; 
    };
  };

  programs.home-manager.enable = true;
}
