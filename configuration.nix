{ config, pkgs, pkgs-stable, ... }:
{

  ## Temporarily until I get real memory installed
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 64*1024; 
  }];

  ## Nix global settings

  nix.settings = {
    experimental-features = [ "nix-command" "flakes"];
    trusted-users = ["root" "ironhandedlayman"];
    auto-optimise-store = true;
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
      "https://cuda-maintainers.cachix.org"
      "https://cache.flox.dev"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    ];
  };

  # Allow unfree packages
  nixpkgs.config = {
    # I guess I need this because of my fonts??? need to investigate further
    permittedInsecurePackages = [ "qtwebengine-5.15.19" ];
    allowUnfree = true;
    # allowBroken = true;
    cudaSupport = true;
  };

  # The GDM greeter ignores org/gnome/desktop/background — its backdrop is the
  # #lockDialogGroup color compiled into gnome-shell-theme.gresource — and
  # shell extensions (e.g. user-theme) never load in the gdm session mode, so
  # dconf/extension approaches can't touch the login screen. The only reliable
  # hook is recompiling that gresource with the wallpaper embedded and our CSS
  # (assets/gdm-greeter.css) appended. Costs a from-source gnome-shell rebuild.
  nixpkgs.overlays = [
    (final: prev: {
      gnome-shell = prev.gnome-shell.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [ final.glib.dev ];
        postFixup = (old.postFixup or "") + ''
          theme=$out/share/gnome-shell/gnome-shell-theme.gresource
          workdir=$(mktemp -d)
          cd $workdir
          for r in $(gresource list $theme); do
            mkdir -p $(dirname .$r)
            gresource extract $theme $r > .$r
          done
          cp ${./assets/wallpapers/forrest-cavale-jwIk4Z3Msi4-unsplash.jpg} \
            org/gnome/shell/theme/gdm-background.jpg
          for css in gnome-shell-dark.css gnome-shell-light.css; do
            cat ${./assets/gdm-greeter.css} >> org/gnome/shell/theme/$css
          done
          {
            echo '<?xml version="1.0" encoding="UTF-8"?>'
            echo '<gresources><gresource prefix="/org/gnome/shell/theme">'
            for f in org/gnome/shell/theme/*; do
              echo "<file>$(basename $f)</file>"
            done
            echo '</gresource></gresources>'
          } > gnome-shell-theme.gresource.xml
          glib-compile-resources --sourcedir=org/gnome/shell/theme \
            --target=$theme gnome-shell-theme.gresource.xml
        '';
      });
    })
  ];

  system.stateVersion = "23.11";

  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    defaultSopsFile = ./secrets/hokusai.yaml;
    secrets.minecraft-server-rcon = {};
  };

  # TODO: move additional hokusai configurations to separate file

  # Hardware configurations
  imports = [
    ./hardware-configuration.nix
  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend=true;
      ignoreUserConfig=true;
      addons = with pkgs; [
        # fcitx5-mozc
        fcitx5-mozc-ut
        fcitx5-gtk
        catppuccin-fcitx5
        qt6Packages.fcitx5-configtool
      ];
      settings = {
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "mosc";
        };
      };
    }; 
  };

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "nvidia_drm.modeset=1"
      "nvidia_drm.fbdev=1"
    ];
    # Load Nvidia KMS modules in the initrd (early KMS) so Plymouth binds to the
    # real Nvidia DRM device from boot instead of the generic simpledrm framebuffer.
    # Without this, plymouth starts fine on simpledrm but gets its framebuffer
    # yanked out from under it a few seconds later when nvidia-drm loads in
    # userspace, causing a flicker/drop to text instead of the themed splash.
    initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        theme = pkgs.catppuccin-grub.override { flavor = "mocha"; };
      };
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
      allowPing = true;

      allowedTCPPorts = [ 
        80 443  # https
        5353    # mdns 
        7100 7000 7001 # airplay
        11434   # ollama 
        10200 10300 # wyoming
      ];
      allowedUDPPortRanges = [
        {from = 4000; to=12000;}
      ];
    };
  };

  hardware = {
    steam-hardware.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        displaylink
        libva-vdpau-driver
        nvidia-vaapi-driver
        libGL
        mesa
        #vulkan-validation-layers
        glfw
        wayland
        libxkbcommon
      ];
    };

    # sane.enable = true; # TODO: as of 12 July 2026 this conflicts with setting in OpenGL, and I need to merge the two setups.

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
    wyoming = {
      # piper.package = pkgs-stable.wyoming-piper;
      piper.servers."hokusai-assist" = {
        enable = true;
        uri = "tcp://0.0.0.0:10200";
        voice = "en_US-hfc_female-medium";
        # zeroconf = {
         #  enable = true;
          # name = "piper-hokusai-assist";
        #} ;
        
        useCUDA = true;
      };
      faster-whisper = {
        # package = pkgs-stable.wyoming-faster-whisper;
        servers."hokusai-assist" = {
          enable = true;
          uri = "tcp://0.0.0.0:10300";
          sttLibrary = "faster-whisper";
          model = "medium";
          language = "en";
          zeroconf = {
            enable = true;
            name = "whisper-hokusai-assist";
          };
          device = "cuda";
        };
      };
    };
    minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true;
      package = pkgs.minecraftServers.vanilla-1-21;
      jvmOpts = "-Xms4096m -Xmx4096m -Djava.net.preferIPv4Stack=true";
    };
    pulseaudio.enable = false; # TODO: remind me why I disabled this?
    playerctld.enable = true;
    pcscd.enable = true;
    monado = {
      enable = false;
      defaultRuntime = true;
      forceDefaultRuntime = true;
    };
    # displaylink.enable = true;
    xserver = {
      videoDrivers = ["nvidia" "displaylink" "modesetting"];
    };

    blueman.enable = true;

    ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      host = "0.0.0.0";
    };

    udev = {
      packages = with pkgs; [
        yubikey-personalization
      ];

    # Extra rules for 8BitDo IDLE 2dc8:3109
    extraRules = ''
        ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="3109", MODE="0666"
        KERNEL=="uinput", MODE="0666"
    '';
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      ipv4 = true;
      ipv6 = true;
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
        hinfo = true;
        domain = true;
        addresses = true;
        workstation = true;
      };    
      reflector=true;
    };
  
    ## Enable the GNOME Desktop Environment.
    displayManager = {
      gdm = {
        enable = true;
        banner=''
          Live well and live broadly.
          You are alive and living now.
          Now is the envy of all the dead.
        '';
      };
    };

    desktopManager.gnome.enable = true;

  # Enable Wayland (enabling xserver is a canard, does not actually enable X11)
  xserver = {
    enable = true;

    ## Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  printing = {
    enable = true;
    logLevel = "debug";
    drivers = [
      pkgs.canon-cups-ufr2
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

  #syncthing = {
  #enable = true;
  #openDefaultPorts = true;
  #extraFlags = ["--no-default-folder"];
  #};
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
    sleep.settings.Sleep = {
      AllowSuspend = "no";
      AllowHibernation = "no";
      AllowHybridSleep = "no";
      AllowSuspendThenHibernate = "no";
    };
    services.avahi-daemon.enable=true;
    services.dlm.wantedBy = ["multi-user.target"];
  };

  powerManagement.enable = false;

  security = {
    pam = {
      services = {
        login.u2fAuth = true;
        sudo.u2fAuth = true;
        hyprlock.u2fAuth = true;
      };
      yubico = {
        enable = true;
        debug = true;
        mode = "challenge-response";
        id = [
          "17951116"
          "17951319"
        ];
      };
    };
      /*
    polkit = {
      enable = false;
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
      */
    rtkit.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
  users.users.ironhandedlayman = {
    isNormalUser = true;
    description = "Ironhandedlayman";
    extraGroups = [ "scanner" "networkmanager" "wheel" "video" "audio" "dialout" "input" "kvm" "render" "polkituser"];
    packages = (with pkgs; [
      firefox-bin
      libnotify
    ]) ++ (with pkgs-stable; [
      yazi
    ]);
  };

  fonts = {
    packages = with pkgs-stable; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts 
    ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs-stable.nerd-fonts);
    fontDir.enable = true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 14d --keep 3";
      flake = "/home/ironhandedlayman/Projects/nix-config#hokusai";
    };

    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    # if you want to pull from another hyprland version (like from the dev version)
    # package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

  };

  envision = {
    enable = false;
    openFirewall = true;
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
    nix-ld = {
      enable = true;
      libraries = with pkgs; [

        wayland
        xcb-util-cursor
        dbus
        dbus-glib
        glib
        glibc
        freetype
        cairo
        clang-tools
        zlib
        libusb1
        libGL 
        libGLU
        libudev-zero
        ncurses
        # fontconfig
        glfw
        SDL
        SDL2
        SDL2_gfx
        SDL2_sound
        SDL2_mixer
        SDL2_image
        SDL2_Pango
        SDL2_ttf
        systemdLibs
        ffmpeg
        udev
        libX11
        libXrandr
        libXcursor
        libXinerama
        libXi
        libXxf86vm
        libxkbcommon
        stdenv.cc.cc.lib
        stdenv.cc.cc.libc_dev
        stdenv.cc.cc.libgcc
        stdenv.cc
        gccNGPackages_15.libstdcxx
        libglvnd
      ];
    };

    git = {
      enable = true;
      lfs.enable = true;
    };
  };

  environment = {
    pathsToLink = [
      "/share/zsh"
      "/usr/lib"
    ];
    shells = with pkgs; [
      bash
      zsh
      fish
      nushell
    ];

    systemPackages = 
    (with pkgs; [
      displaylink
      binutils
      patchelf
      auto-patchelf
      avahi
      brightnessctl
      btop
      cups
      dbus
      dive
      egl-wayland
      foot
      freetype
      # freecad-wayland # NOTE: crashes build as of 4 Nov 2025, need to revisit when it doesn't crash the build
      gcc
      glfw
      mesa-demos
      godot_4
      go
      grim
      gutenprint
      gutenprintBin
      cage
      wl-mirror
      hyprpaper
      hyprpicker
      hyprlock
      hypridle
      hyprpolkitagent
      inetutils
      jq
      lf
      libreoffice
      linux-firmware
      lshw
      mako
      mesa
      nemo-with-extensions
      nix-index
      ngspice
      nsncd
      nvtopPackages.full
      pavucontrol
      pciutils
      pikopixel
      pkg-config
      podman-tui
      prusa-slicer
      qpwgraph
      rclone
      rclone-browser
      screenkey
      slop
      SDL2
      SDL2_ttf
      SDL2_mixer
      SDL2_gfx
      SDL2_image
      SDL2_sound
      slurp
      socat
      tree
      unscd
      unzip
      usbimager
      usbutils
      uv
      uxplay
      # vkmark -- TODO: Revisit on 18 Jan 2025, does not compile 4 Jan 2025
      vulkan-tools
      wally-cli
      waybar
      wayland
      wayland-scanner
      wshowkeys
      wget
      wl-clipboard
      wlr-randr
      wofi
      xclip
      yq
      yubioath-flutter
      zoom-us
      sops
      age
      tldr
      #sonic-pi
    ]) ++ 
    (with pkgs-stable; [
      canon-cups-ufr2
    kicad
    openscad
    (rofi.override { plugins = with pkgs-stable; [
      rofi-calc
      rofi-file-browser
      rofi-emoji
      rofi-screenshot
      rofi-top
    ];})
    vim 
    bottles
  ])++ 
  (with pkgs.nltk-data; [
    words
    wordnet
    wordnet31
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
#     WLR_DRM_NO_MODIFIERS="1";
WLR_NO_HARDWARE_CURSORS = "1";
LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib";          
DG_SESSION_TYPE = "wayland";
#      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
NIXOS_OZONE_WL = "1";
    };
  };
  system.activationScripts.text = "
  if [ ! -d /usr/share/nltk_data/corpora ]; then
  mkdir -p /usr/share/nltk_data/corpora
  fi
  # ln -sf ${pkgs.nltk-data.words}/corpora/words /usr/share/nltk_data/corpora/words
  # ln -sf ${pkgs.nltk-data.wordnet}/corpora/wordnet /usr/share/nltk_data/corpora/wordnet
  # ln -sf ${pkgs.nltk-data.wordnet31}/corpora/wordnet31 /usr/share/nltk_data/corpora/wordnet31
  ";
}
