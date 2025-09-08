{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    gnupg
    pinentry
    fastfetch
    fzf
    hexedit
    hexyl
    love
    lsix
    nvme-cli
    (python313.withPackages ( pythonPkgs: with pythonPkgs; [
      nltk
      fastapi
      flask
      nltk-data
      pyglm
      manim
      manim-slides
      numpy
      pyarrow
      torch
      torchvision
      torchaudio
      pandas
      # parquet # missing toml package? broken as of 2 Sept 2025
      pip
      polars
      pygame
      ray
      requests
      ultralytics
    ]))
    parquet-tools
    ripgrep
    tmux
    xxd
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    sessionVariables = {
      EDITOR = "nvim";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "fzf"
        "kubectl"
      ];
      theme = "agnoster";
    };
    shellAliases = {
      ll = "exa --icons -l";
    };
    initContent = ''
      source <(nh completions zsh) 
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
      # nix details of package
      ndet () {
        nix eval --json -f "<nixpkgs>" $1.meta | jq
      }
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
