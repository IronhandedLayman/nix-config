# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-stable, vivepro2Driver, ... }:
{
  ## Nix global settings

  nix.settings = {
    experimental-features = [ "nix-command" "flakes"];
    auto-optimise-store = true;
  }; 

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # Hardware configurations
  imports = [
      ./hardware-configuration.nix
  ];
  
  # Additional hokusai configurations TODO: move to separate file

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      nvidia-vaapi-driver
#      vulkan-validation-layers
    ];
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Extra rules for 8BitDo IDLE 2dc8:3109
  services.udev.extraRules = ''
     ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="3109", MODE="0666"
  '';

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_6_11;
    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
      "initcall_blacklist=simpledrm_platform_driver_init"
    ];
  #  kernelPatches = vivepro2Driver.kernelPatches;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };


  networking.hostName = "hokusai"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # turn off sleep suspend
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # turn off power management
  powerManagement.enable = false;


  services.avahi = {
    enable = true;
    nssmdns4 = true;
    ipv4 = true;
    ipv6 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };    
  };

  # Enable Wayland (enabling xserver is a canard, does not actually enable X11)
  services.xserver = {
    enable = true;

    ## Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    desktopManager.gnome.enable = true;

    ## Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";
  };

  security.polkit.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # Enable sound with pipewire.
  # sound.enable = true; # nixos considers this deprecated 19 Jun 2024
  hardware.pulseaudio.enable = false;
  services.blueman.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ironhandedlayman = {
    isNormalUser = true;
    description = "Ironhandedlayman";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" "kvm" "render" "polkituser"];
    packages = (with pkgs; [
      firefox
      libnotify
    ]) ++ (with pkgs-stable; [
      yazi
    ]);
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 14d --keep 3";
    flake = "/home/ironhandedlayman/Projects/nix-config#hokusai";
  };

  # programs.sway = {
    # enable = true;
    # wrapperFeatures.gtk = true;
    # extraOptions = [
      # "--unsupported-gpu"
    # ];
    # extraPackages = with pkgs; [
      # swaylock
      # swayidle
    # ];
    # extraSessionCommands = ''
      # export MOZ_ENABLE_WAYLAND=1;
      # export WLR_DRM_NO_MODIFIERS=1;
      # export WLR_DRM_DEVICES=/dev/dri/card1;
   # '';
  # }; 
  
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    # package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  fonts.packages = with pkgs-stable; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nerdfonts
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts 
  ];

  environment = {
    systemPackages = 
    (with pkgs; [
      avahi
      brightnessctl
      btop
      cups
      canon-cups-ufr2
      foot
      dbus
      egl-wayland
      glxinfo
      grim
      inetutils
      lf
      linux-firmware
      lshw
      mako
      mesa
      nemo-with-extensions
      nvtopPackages.full
      nsncd
      pavucontrol
      pciutils
      podman-tui
      dive
      slurp
      socat
      unscd
      usbimager
      usbutils
      vkmark
      vulkan-tools
      waybar
      wayland
      wayland-scanner
      wget
      wl-clipboard
      wofi
      hyprlandPlugins.hy3
      hyprpaper
      hyprpicker
    ]) ++ 
    (with pkgs-stable; [
      vim 
    ]);
   # ++
   # (with hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}; [
   # ]);
    sessionVariables = rec {
      GBM_BACKEND = "nvidia-drm";
      LIBVA_DRIVER_NAME = "nvidia";
      MOZ_ENABLE_WAYLAND="1";
#     WLR_DRM_DEVICES="/dev/dri/card1";
#      WLR_DRM_NO_MODIFIERS="1";
      WLR_NO_HARDWARE_CURSORS = "1";
      LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib";          
      XDG_SESSION_TYPE = "wayland";
#      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NIXOS_OZONE_WL = "1";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # shells
  environment.shells = with pkgs; [
    bash
    zsh
    fish
    oils-for-unix
    nushell
  ];
  
  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;

  # Gaming settings
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;

}
