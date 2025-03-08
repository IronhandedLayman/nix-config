{ config, pkgs, lib, ... }:
let 
  username="ironhandedlayman";
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
      nvd
      protonup
      wlr-randr
      pyradio
      vlc
      poppler_utils
    ];

    file = {
    };
  
    sessionVariables = {
      EDITOR = lib.mkForce "nvim";
      DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox"; # NOTE: think about other browsers given events around 27-Feb-25
    };
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
