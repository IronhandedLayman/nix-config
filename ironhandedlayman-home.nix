{ config, pkgs, lib, ... }:
let 
  username="ironhandedlayman";
  flakerepo="Projects/nix-config";
in {

  imports = [
    ./neovim.nix          # imports nixvim settings
    ./shell.nix           # general shell preferences
    ./windowmanager.nix   # preferred window manager settings, terminal, and keyboard bindings
  ]; 

  xdg.dataFile."fonts" = {
    enable = true;
    source = config.lib.file.mkOutOfStoreSymlink "/run/current-system/sw/share/X11/fonts";
  };

  home = {
    stateVersion = "23.11"; 

    username = "${username}";
    homeDirectory = "/home/${username}";

    packages = with pkgs; [
      bitwarden-cli
      bitwarden-menu
      bitwarden-desktop
      buf
      cmake
      delve
      devenv
      duf
      eza
      fd
      gcc
      gh
      gnumake
      kubernetes-helm
      k3s
      k9s
      kdePackages.kdenlive
      kiwix
      inkscape-with-extensions
      # manim  # Note: including in python deployment since I want detection of modules in nvim
      opentofu
      ncdu
      nvd
      protonup-ng
      qucs-s
      wlr-randr
      pyradio
      ruff
      taplo
      vlc
      poppler-utils
      # sonic-pi
      just
      opentofu
      openstackclient
    ];

    file = {
    };
  
    sessionVariables = {
      EDITOR = lib.mkForce "nvim";
      DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox"; # NOTE: think about other browsers given events around 27-Feb-25
      FLAKE = "/home/${username}/${flakerepo}";
      NH_FLAKE = "/home/${username}/${flakerepo}";
    };
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      # obs-color-monitor
      obs-gstreamer
      #obs-pipewire-audio-capture
      #obs-source-switcher
      #advanced-scene-switcher
      #obs-advanced-masks
      #input-overlay
    ];
  };

  programs.git = {
    enable = true;
    settings = {
      aliases = {
        c = "commit --no-verify -a";
        adog = "log --all --decorate --oneline --graph";
      };
      user.name = "ironhandedlayman";
      user.email = "leadhyena@gmail.com";
      branch.sort = "committerdate";
      tag.sort = "version:refname";
      column.ui="auto";
      color.ui="true";
      commit.verbose = true;
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };
      lfs = {
        enable = true;
        skipSmudge = true;
      };
      pull.rebase = false; # NOTE: revisit this stance
      merge.tool = "meld";
      help.autocorrect = "prompt";
      init.defaultBranch = "main"; 
    };
  };

  programs.home-manager = {
    enable = true;
  };
}
