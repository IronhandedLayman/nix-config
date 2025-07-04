{ config, pkgs, nixvim, ... }:
rec {
  imports = [
    ./neovim.nix # imports nixvim settings
  ];
  home.username = "ironhandedlayman";
  home.homeDirectory = "/home/${home.username}";

  programs.zsh = {
    enable = true;
    source = config.lib.file.mkOutOfStoreSymlink "/run/current-system/sw/share/X11/fonts";
  };

  home = {
    stateVersion = "23.11";

    username = "${username}";
    homeDirectory = "/home/${username}";

    packages = with pkgs; [
      bitwarden
      bitwarden-cli
      bitwarden-menu
      bitwarden-desktop
      buf
      cmake
      delve
      duf
      eza
      fd
      gcc
      gnumake
      k3s
      kdePackages.kdenlive
      inkscape-with-extensions
      ncdu
      nvd
      protonup
      wlr-randr
      pyradio
      vlc
      poppler_utils
      # sonic-pi
      just
      opentofu
      openstackclient
    ];

    file = { };

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
      today () {
        nvim +Neorg\ journal\ today
      }
      wiki () {
        nvim +Neorg\ index
      }
      wp () {
        mon=`hyprctl monitors | awk '/^Monitor/{print $2}' | fzf --height=6`
        echo "will change monitor $mon"
      }
    '';
  };

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    fastfetch
    protonup
    wlr-randr
    joplin
    joplin-desktop
    fzf
    lsix
    love
    bat
    imhex
    hexyl
    hexedit
    xxd
    tmux
    nvme-cli
    nh
    nvd
  ];

  # TODO: reenable when flakes are finally brought current
  # programs.nh = {
  # enable = true;
  # clean.enable = true;
  # clean.extraArgs = "--keep-since 14d --keep 3";
  # flake = "${home.homeDirectory}/Projects/nix-config#hokusai";
  # };

  home.file = { };

  home.sessionVariables = { };

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
        alpha = "0.8";
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
