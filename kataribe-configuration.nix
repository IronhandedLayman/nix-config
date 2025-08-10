{ config, pkgs, username, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowBroken = true;
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
      alacritty
      wezterm
      vim
      neovim
      btop
      docker
      colima
    ];

  nix = {
    package = pkgs.nix;
    settings = {
      trusted-users = [ "@admin" "${username}" ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system = {
    primaryUser = "${username}";
    stateVersion = 4;
    defaults = {
      LaunchServices = {
        LSQuarantine = false;
      };
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };
      dock = {
        autohide = false;
        show-recents = false;
        launchanim = true;
        mouse-over-hilite-stack = true;
        orientation = "bottom";
        tilesize = 48;
      };
      finder = {
        _FXShowPosixPathInTitle = false;
      };
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };


  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  # programs.fish.enable = true;

  users.users.ironhandedlayman = {
    name = "ironhandedlayman";
    home = "/Users/ironhandedlayman";
    isHidden = false;
    shell = pkgs.zsh;
    description = "Ironhandedlayman";
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  documentation.enable = false;
}
