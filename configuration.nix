{ config, pkgs, pkgs-stable, ... }:
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

  system.stateVersion = "23.11";

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
#      "initcall_blacklist=simpledrm_platform_driver_init" # NOTE: 2025-03-30 this was commented out. Safe to remove 2025-05-01
    ];
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
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };

  services = {
    pulseaudio.enable = false;
    playerctld.enable = true;
    xserver = {
      videoDrivers = ["nvidia"];
    };

    blueman.enable = true;

    ollama = {
      enable = true;
      acceleration = "cuda";
      host = "0.0.0.0";
    };

    monado = {
      enable = true;
      defaultRuntime = true;
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
  printing = {
    enable = true;
    drivers = [
      pkgs.canon-capt
      pkgs-stable.canon-cups-ufr2
    ];
  };

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

  systemd = {
    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
      AllowHybridSleep=no
      AllowSuspendThenHibernate=no
    '';
    user.services.monado.environment = {
      STEAMVR_LH_ENABLE = "1";
      XRT_COMPOSITOR_COMPUTE = "1";
      WMR_HANDTRACKING = "0";
    };
  };

  powerManagement.enable = false;

  security.polkit = {
    enable = true;
    extraConfig ='' 
    polkit.addRule(function (action, subject) {
    const setcapBinary = "/usr/bin/setcap";
    const allowedCapability = "CAP_SYS_NICE=eip";
    const steamVrCompositorLauncherBinary = "/home/" + subject.user + "/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher";
    const steamVrCompositorLauncherBinaryAlt = "/home/" + subject.user + "/.steam/steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher";
    const monadoServiceBinary = "/run/wrappers/bin/monado-service";

    if (action.id == "org.freedesktop.policykit.exec" &&
        action.lookup("program") == setcapBinary) {
        // Check if action has "command_line" key
        if (action.lookup("command_line")) {
            const argv = action.lookup('command_line').split(' ');
        }
        if (argv && argv.length == 3 &&
            argv[1] == allowedCapability &&
            (argv[2] == steamVrCompositorLauncherBinary ||
            argv[2] == steamVrCompositorLauncherBinaryAlt)) {
            polkit.log("Allowed setcap CAP_SYS_NICE=eip for SteamVR compositor launcher as requested by user '" + subject.user + "'");
            return polkit.Result.YES;
        } else if (argv && argv.length == 3 &&
            argv[1] == allowedCapability &&
            argv[2] == monadoServiceBinary) {
            polkit.log("Allowed setcap CAP_SYS_NICE=eip for Monado Service as requested by user '" + subject.user + "'");
            return polkit.Result.YES;
        }
    }
    });
    '';
  };
  security.rtkit.enable = true;

  users.defaultUserShell = pkgs.zsh;
  users.users.ironhandedlayman = {
    isNormalUser = true;
    description = "Ironhandedlayman";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "dialout" "input" "kvm" "render" "polkituser"];
    packages = (with pkgs; [
      firefox
      libnotify
    ]) ++ (with pkgs-stable; [
      yazi
    ]);
  };

  fonts = {
    packages = with pkgs-stable; [
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
    fontDir.enable = true;
  };

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
    # if you want to pull from another hyprland version (like from the dev version)
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
    extraCompatPackages=with pkgs; [proton-ge-bin];
  };

  gamemode.enable = true;
  nix-ld.enable = true;

  git = {
    enable = true;
    lfs.enable = true;
  };
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
    cups
    dbus
    devenv
    dive
    egl-wayland
    foot
    freecad-wayland
    gcc
    glfw-wayland
    glxinfo
    godot_4
    go
    grim
    gutenprint
    gutenprintBin
    hyprpaper
    hyprpicker
    inetutils
    jq
    kicad
    lf
    libreoffice
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
    (rofi-wayland.override { plugins = with pkgs; [
      rofi-calc
      rofi-file-browser
      rofi-emoji-wayland
      rofi-screenshot
      rofi-top
    ];})
    qpwgraph
    SDL2
    SDL2_gfx
    SDL2_image
    SDL2_sound
    slurp
    socat
    tree
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
    wlr-randr
    wofi
    xclip
    xorg.libX11
    yq
  ]) ++ 
  (with pkgs-stable; [
    canon-cups-ufr2
    openscad
    vim 
  ]);
   # This section below also allows you to add packages from hyprland's package selection
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
