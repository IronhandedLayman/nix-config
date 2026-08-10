{ config, pkgs, pkgs-stable, lib, ... }:
let 
  username="ironhandedlayman";
  flakerepo="Projects/nix-config";
in {

  imports = [
    ./packages/module.nix # bespoke packages from ./packages, toggled via bespoke.<name>.enable
    ./neovim.nix          # imports nixvim settings
    ./shell.nix           # general shell preferences
    ./windowmanager.nix   # preferred window manager settings, terminal, and keyboard bindings
  ]; 

  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
      };
    };
    dataFile."fonts" = {
      enable = true;
      source = config.lib.file.mkOutOfStoreSymlink "/run/current-system/sw/share/X11/fonts";
    };
  };

  home = {
    stateVersion = "23.11"; 

    username = "${username}";
    homeDirectory = "/home/${username}";

    pointerCursor.enable=true;

    packages = (with pkgs; [
      television
      # manim  # using it here because python manim is broken
      # sonic-pi
      bitwarden-cli
      # bitwarden-desktop
      bitwarden-menu
      buf
      ckan
      claude-code
      cmake
      gdb
      delve
      devenv
      duf
      eza
      fd
      gcc
      gh
      gnumake
      inkscape-with-extensions
      just
      k3s
      k9s
      kiwix
      kubernetes-helm
      ncdu
      nvd
      openstackclient
      opentofu
      opencode
      opencode-claude-auth
      poppler-utils
      prismlauncher
      protonup-ng
      pyradio
      qucs-s
      ruff
      taplo
      terraform
      viddy
      vlc
      wlr-randr
      (sbcl.withPackages (ps: with ps; [
        alexandria
      ]))
      cl-launch
    ]) ++ (with pkgs-stable;[
      kdePackages.kdenlive
    ]);

    file = {
    };
  
    sessionVariables = {
      EDITOR = lib.mkForce "nvim";
      DEFAULT_BROWSER = "${pkgs.firefox-bin}/bin/firefox"; # NOTE: think about other browsers given events around 27-Feb-25
      FLAKE = "/home/${username}/${flakerepo}";
      NH_FLAKE = "/home/${username}/${flakerepo}";
    };
  };

  bespoke.nebius-cli.enable = true;
  bespoke.sonar.enable = true;
  bespoke.usagi.enable = true;

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
    signing.format = null;
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
