{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    gnupg
    pinentry-gnome3
    fastfetch
    fzf
    hexedit
    hexyl
    love
    lsix
    nvme-cli
    (python314.withPackages ( pythonPkgs: with pythonPkgs; [
      # gguf # TODO: does not build 27 Feb 2026
      # llm-gguf # TODO: revisit 18 Jan 2025 does not pass tests
      nltk
      fastapi
      flask
      nltk-data
      pyglm
      # manim
      # manim-slides
      numpy
      pyarrow
      torch
      torchvision
      #torchaudio
      pandas
      # parquet # missing toml package? broken as of 2 Sept 2025
      pip
      polars
      # pygame
      # ray
      requests
      ultralytics
    ]))
    parquet-tools
    ripgrep
    (ruby.withPackages (ps: with ps; [
      racc
      rbs
    ]))
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
      # took out completions for nh, since they aren't supported the same way as before? 3 mar 2026
      # source <(nh completions zsh) 

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
      export PATH=/home/ironhandedlayman/bin:$PATH
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
