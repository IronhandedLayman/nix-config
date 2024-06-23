{ config, pkgs, nixvim, ... }:
{
  home.username = "ironhandedlayman";
  home.homeDirectory = "/home/ironhandedlayman";

  home.stateVersion = "23.11"; 

  home.packages = with pkgs; [
    fastfetch
    protonup
    joplin
    joplin-desktop 
    love
    tmux
  ];

  home.file = {
  };

  home.sessionVariables = {
  };

  programs.nixvim = {
    enable = true;
    clipboard.providers.wl-copy.enable = true;
    colorschemes.base16 = {
      enable = true;
      colorscheme = "atelier-dune";
    };
    plugins = {
      sleuth.enable = true;
      bufferline.enable = true;
      comment.enable = true;
      telescope.enable = true;
      lightline.enable = true;
      fugitive.enable = true;
      gitgutter.enable = true;
      treesitter = {
        enable = true;
        ensureInstalled = "all";
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
