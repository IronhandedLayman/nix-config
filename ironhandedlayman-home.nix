{ config, pkgs, nixvim, ... }:
{
  imports = [
    ./neovim.nix # imports nixvim settings
  ]; 
  home.username = "ironhandedlayman";
  home.homeDirectory = "/home/ironhandedlayman";

  home.stateVersion = "23.11"; 

  home.packages = with pkgs; [
    fastfetch
    protonup
#    joplin
#    joplin-desktop 
    love
    bat
    imhex
    hexyl
    hexedit
    xxd
    tmux
  ];

  home.file = {
  };

  home.sessionVariables = {
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "Hack:size=12";
        dpi-aware = "yes";
      };
      mouse = {
        hide-while-typing = "yes";
      };
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
