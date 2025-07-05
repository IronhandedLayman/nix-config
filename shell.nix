{ pkgs, system, ... }:
{
  home.packages = with pkgs; [
    bat
    gnupg
    fastfetch
    fzf
    hexedit
    hexyl
    lsix
    (python313.withPackages (pythonPkgs: with pythonPkgs; [
      nltk
      nltk-data
      numpy
      pyarrow
      torch
      pandas
      parquet
      requests
    ]))
    parquet-tools
    ripgrep
    tmux
    xxd
  ] ++ (if (system == "x86_64-linux") then [
    love
    pinentry
    nvme-cli
  ] else [ ]);

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
      # nix search
      nsearch () {
        nix search nixpkgs $1 2>/dev/null
      }
      # nix details of package
      ndet () {
        nix eval --json -f "<nixpkgs>" $1.meta | jq
      }
    '' + (if (system == "x86_64-linux") then
      (
        ''
          wp () {
            mon=`hyprctl monitors | awk '/^Monitor/{print $2}' | fzf --height=6`
            echo "will change monitor $mon"
          }
        ''
      ) else "");
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
