{ config, pkgs, username, system, ... }:
{
  imports = [
    ./neovim.nix # imports nixvim settings
    ./shell.nix
  ];

  home = {
    stateVersion = "23.11";

    username = "${username}";
    homeDirectory = "/home/${username}";

    packages = with pkgs; [
      bat
      bitwarden
      bitwarden-cli
      bitwarden-desktop
      bitwarden-menu
      buf
      cmake
      delve
      duf
      eza
      fastfetch
      fd
      fzf
      gcc
      gh
      gnumake
      hexedit
      hexyl
      imhex
      inkscape-with-extensions
      just
      k3s
      love
      lsix
      ncdu
      nh
      nvd
      nvme-cli
      openstackclient
      opentofu
      poppler_utils
      pyradio
      ruff
      taplo
      tmux
      vlc
      xxd
    ] ++ (if (system == "x86_64-linux") then
      (with pkgs; [
        kdePackages.kdenlive
        protonup
        wlr-randr
      ]) else [ ]);

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
    '' ++ (if (system == "x86_64-linux") then
      (
        ''
          wp () {
            mon=`hyprctl monitors | awk '/^Monitor/{print $2}' | fzf --height=6`
            echo "will change monitor $mon"
          }
        ''
      ) else "");
  };

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

  programs.zsh = {
    enable = true;
    source = config.lib.file.mkOutOfStoreSymlink "/run/current-system/sw/share/X11/fonts";
  };


  programs.home-manager.enable = true;
}
