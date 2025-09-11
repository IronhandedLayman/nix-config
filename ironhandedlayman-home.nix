{ config, pkgs, lib, username, system, hostname, ... }:
let
  flakerepo = "projects/nix-config";
in
rec
{
  imports = [
    ./neovim.nix # imports nixvim settings
    ./shell.nix
  ];

    # ./windowmanager.nix   # preferred window manager settings, terminal, and keyboard bindings

  xdg.dataFile."fonts" = lib.mkIf (system == "x86_64-linux") {
    enable = true;
    source = config.lib.file.mkOutOfStoreSymlink "/run/current-system/sw/share/X11/fonts";
  };

  home = {
    # homeDirectory = if (system == "x86_64-linux") then /home/${username} else /Users/${username};
    homeDirectory = "/Users/${username}";

    packages = with pkgs; [
      bat
      bitwarden
      bitwarden-cli
      bitwarden-menu
      bitwarden-desktop
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
      go
      gnumake
      hexedit
      hexyl
      imhex
      just
      lsix
      ncdu
      nh
      nvd
      openstackclient
      opentofu
      poppler_utils
      pyradio
      ruff
      taplo
      tmux
      uv
      xxd
    ] ++ (if (system == "x86_64-linux") then
      (with pkgs; [
        kdePackages.kdenlive
        k3s
        nvme-cli
        love
        protonup
        wlr-randr
        inkscape-with-extensions
        vlc
      ]) else [ ]);

    file = { };
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 14d --keep 3";
    flake = "${home.homeDirectory}/Projects/nix-config#${hostname}";
  };

  home.file = { };

  home.sessionVariables = {
    EDITOR = lib.mkForce "nvim";
    # DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox"; # NOTE: think about other browsers given events around 27-Feb-25
    FLAKE = "${home.homeDirectory}/${username}/${flakerepo}";
    # TODO: why is this defined in multiple places???
    # NH_FLAKE = "${home.homeDirectory}/${username}/${flakerepo}";
  };

  programs.foot = lib.mkIf (system == "x86_64-linux") {
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

  programs.obs-studio = lib.mkIf (system == "x86_64-linux") {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-color-monitor
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
    userName = "ironhandedlayman";
    userEmail = "leadhyena@gmail.com";
    aliases = {
      c = "commit --no-verify -a";
      adog = "log --all --decorate --oneline --graph";
    };
    extraConfig = {
      branch.sort = "committerdate";
      tag.sort = "version:refname";
      column.ui = "auto";
      color.ui = "true";
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
