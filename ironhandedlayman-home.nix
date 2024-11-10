{ config, pkgs, nixvim, ... }:
rec {
  imports = [
    ./neovim.nix # imports nixvim settings
  ]; 
  home.username = "ironhandedlayman";
  home.homeDirectory = "/home/${home.username}";

  programs.zsh = {
    enable = true;
    sessionVariables = {
      EDITOR = "nvim";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "fzf"
      ];
      theme = "agnoster";
    };
    initExtra = ''
      source <(nh completions --shell zsh) 
      # routes to Neorg's journal system
      today () {
        nvim +Neorg\ journal\ today
      }
      # routes to Neorg's wiki
      wiki () {
        nvim +Neorg\ index
      }
      # selecting monitor information in hyprland
      wp () {
        mon=`hyprctl monitors | awk '/^Monitor/{print $2}' | fzf --height=6`
        echo "will change monitor $mon"
      }
      # nix search
      nsearch () {
        nix search nixpkgs $1 2>/dev/null
      }
    '';
  };

  home.stateVersion = "23.11"; 

  home.packages = with pkgs; [
    bat
    fastfetch
    fzf
    hexedit
    hexyl
    imhex
    joplin
    joplin-desktop 
    love
    lsix
    nvd
    nvme-cli
    protonup
    python313
    ripgrep
    tmux
    wlr-randr
    xxd
  ];

  home.file = {
  };

  home.sessionVariables = {
    test = "foo";
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "Hack Nerd Font Mono:size=8";
        dpi-aware = "yes";
      };
      mouse = {
        hide-when-typing = "yes";
      };
      colors = {
        alpha="0.8";
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
