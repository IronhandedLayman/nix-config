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

  # TODO: move additional hokusai configurations to separate file

  # Hardware configurations
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
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

networking = {
  hostName = "hokusai"; 
  networkmanager.enable = true;
  firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 5353 11434 ];
    allowedUDPPortRanges = [
      {from = 4000; to=12000;}
    ];
  };
};

hardware = {
  pulseaudio.enable = false;

  graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      nvidia-vaapi-driver
        #vulkan-validation-layers
      ];
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  services = {
    xserver.videoDrivers = ["nvidia"];

    blueman.enable = true;

    ollama = {
      enable = true;
      acceleration = "cuda";
      host = "0.0.0.0";
    };

  # Extra rules for 8BitDo IDLE 2dc8:3109
  udev.extraRules = ''
      ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="3109", MODE="0666"
  '';

  avahi = {
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
  xserver = {
    enable = true;

    ## Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    desktopManager.gnome.enable = true;

    ## Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  printing.enable = true;

  openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  pipewire = {
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
};

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

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  powerManagement.enable = false;

  security.polkit.enable = true;
  security.rtkit.enable = true;

  users.defaultUserShell = pkgs.zsh;
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

  programs = {
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 14d --keep 3";
      flake = "/home/ironhandedlayman/Projects/nix-config#hokusai";
    };

    hyprland = {
      enable = true;
      xwayland.enable = true;
    # package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  zsh.enable = true;

  # Gaming settings
  steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  gamemode.enable = true;
  nix-ld.enable = true;
};

environment = {
  shells = with pkgs; [
    bash
    zsh
    fish
    oils-for-unix
    nushell
  ];

  systemPackages = 
  (with pkgs; [
    avahi
    brightnessctl
    btop
    canon-cups-ufr2
    cups
    dbus
    dive
    egl-wayland
    foot
    freecad-wayland
    gcc
    glfw-wayland
    glxinfo
    go
    grim
    hyprpaper
    hyprpicker
    inetutils
    kicad
    lf
    linux-firmware
    lshw
    mako
    mesa
    nemo-with-extensions
    ngspice
    nsncd
    nvtopPackages.full
    pavucontrol
    pciutils
    podman-tui
    prusa-slicer
    SDL2
    SDL2_gfx
    SDL2_image
    SDL2_sound
    slurp
    socat
    unscd
    usbimager
    usbutils
    uv
    vkmark
    vulkan-tools
    waybar
    wayland
    wayland-scanner
    wget
    wl-clipboard
    wofi
    xorg.libX11
  ]) ++ 
  (with pkgs-stable; [
    openscad
    vim 
  ]);
   # ++
   # (with hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}; [
   # ]);
   sessionVariables = {
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
}
