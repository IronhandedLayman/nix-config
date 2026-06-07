{ pkgs, pkgs-stable, ... }:
{
  home.packages = with pkgs; [
    waybar-mpris
    grimblast
    rofi-calc
    rofi-file-browser
    rofi-emoji
  ];

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  programs.foot = {
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
      colors-dark = {
        alpha="0.8";
      }; 
    };
  };

  programs.rofi = {
    enable = true;
    cycle = true;
    font = "Hack Nerd Font 12";
    terminal = "${pkgs.foot}/bin/foot";
    theme = "Indego";
    package = pkgs-stable.rofi;
    plugins = with pkgs-stable; [
      rofi-calc
      rofi-file-browser
      rofi-emoji
    ];
    modes = [
      "drun"
    ];
    extraConfig = {
      matching = "fuzzy";
#      combi-modes = [
#        "drun"
#        "window"
#        "run"
#      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    configType="hyprlang"; # NOTE: revisit after 26.05 release
    xwayland.enable = true;

    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    # as per Hyprland Wiki https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/
    package = null;
    portalPackage = null;

    settings = {
      # internal Hyprland vars
      "$fileManager" = "${pkgs.yazi}/bin/yazi";
      # "$menu" = "${pkgs.wofi}/bin/wofi --show drun";
      "$menu" = "${pkgs.rofi}/bin/rofi -show combi";
      "$altmenu" = "${pkgs.rofi}/bin/rofi -plugin-path ${pkgs.rofi}/lib/rofi -mode calc -show calc";
      "$terminal" = "${pkgs.foot}/bin/foot";
      "$mod" = "MOD4";
      "$rightMon" = "HDMI-A-1";
      "$leftMon" = "HDMI-A-2";
      "$elgProm" = "DVI-I-1";

      monitor = [
        "$rightMon, 3840x2160@120, 0x0, 1,vrr,1"
        "$leftMon, 3840x2160, -3840x0, 1"
        "$elgProm, 1024x600, 0x-600, 1"
      ];

      workspace = builtins.concatLists (builtins.genList (i:
      let 
        ls = toString (2*i+2); 
        rs = toString (2*i+1); 
        defme = if i==0 then ", default:true" else "";
      in [
        "${ls}, monitor:$leftMon${defme}"
        "${rs}, monitor:$rightMon${defme}"
      ]) 5 );

      exec-once = [
        #"${pkgs.waybar}/bin/waybar &" # evidently this loads automatically? let's find out.
        "${pkgs.hyprpaper}/bin/hyprpaper &"
        "${pkgs.waybar}/bin/waybar"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORMTHEME,qt5ct" # change to qt6ct if you have that
        # for NVIDIA, not sure if necessary, will try it
        "LIBVA_DRIVER_NAME,nvidia"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];

      # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0; # -1.0 to 1.0, 0 means no modification.
      };

      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        layout = "dwindle";

        allow_tearing = false; # not ready for it yet TODO 2025-02-23 try this again?
      };

      # once tearing works, test with the below
      # windowrulev2 = immediate, class:^(factorio)$
      # windowrulev2 = immediate, class:^(steam)$

      decoration = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          rounding = 10;

          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };

      #    drop_shadow = yes
      #    shadow_range = 4
      ##    shadow_render_power = 3
      #       col.shadow = rgba(1a1a1aee)
    };

    animations = {
      enabled = true;

          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        dwindle = {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          # pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          "preserve_split" = true; # you probably want this;
        };

        misc = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          force_default_wallpaper = 0; # Set to 0 or 1 to disable the anime mascot wallpapers
          # vrr = 1
        };

        # windowrule = "suppressevent maximize, class:.*"; # You'll probably like this.


        "$mainMod" = "MOD4";
        bind = [
          "$mainMod, Return, exec, $terminal"
          "$mainMod, Q, killactive, "
          "$mainMod, E, exit, "
          "$mainMod, F, fullscreen"
          "$mainMod, G, exec, $terminal $fileManager"
          "$mainMod, V, togglefloating, "
          "$mainMod, D, exec, $menu"
          "$mainMod, B, exec, $altmenu"
          #"$mainMod, P, pseudo, " # dwindle
          #"$mainMod, C, togglesplit, " # dwindle
          "$mainMod, X, movewindow, mon:+1"

          "$mainMod, H, movefocus, l"
          "$mainMod, L, movefocus, r"
          "$mainMod, J, movefocus, u"
          "$mainMod, K, movefocus, d"
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
        ]
        ++ ( builtins.concatLists (builtins.genList (i:
        let ws = toString (i+1); in [
          "$mainMod, ${ws}, workspace, ${ws}"
          "$mainMod SHIFT, ${ws}, movetoworkspace, ${ws}"
        ]) 9 ));

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

      };
      systemd = {
        enable = true;
        variables = ["--all"];
      };
    };

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          spacing = 4;
          output = [
            "HDMI-A-1"
            "HDMI-A-2"
          ];
          modules-left = [
            "hyprland/workspaces"
            "hyprland/submap"
            "mpris"
          ];
          modules-center = [
            "hyprland/window"
          ];
          modules-right = [
            "idle-inhibitor"
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "temperature"
            "clock"
            "tray"
          ];

          "idle_inhibitor"= {
            "format"="{icon}";
            "format-icons"= {
              "activated"= "";
              "deactivated"= "";
            };
          };
          "tray"= {
            "spacing"= 10;
          };
          "clock"= {
            "tooltip-format"= "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            "format-alt"= "{:%Y-%m-%d}";
            "calendar"= {
              "mode"          = "year";
              "mode-mon-col"  = 3;
              "weeks-pos"     = "right";
              "on-scroll"     = 1;
              "on-click-right"= "mode";
              "format"= {
                "months"=     "<span color='#ffead3'><b>{}</b></span>";
                "days"=       "<span color='#ecc6d9'><b>{}</b></span>";
                "weeks"=      "<span color='#99ffdd'><b>W{}</b></span>";
                "weekdays"=   "<span color='#ffcc66'><b>{}</b></span>";
                "today"=      "<span color='#ff6699'><b><u>{}</u></b></span>";
              };
            };
            "actions"= {
              "on-click-right"= "mode";
              "on-click-forward"= "tz_up";
              "on-click-backward"= "tz_down";
              "on-scroll-up"= "shift_up";
              "on-scroll-down"= "shift_down";
            };
          };
          "cpu"= {
          "format"= "{usage}% ";
          "tooltip"= false;
          };
          "memory"= {
          "format"= "{}% ";
          };
          "temperature"= {
        # "thermal-zone"= 2;
        # "hwmon-path"= "/sys/class/hwmon/hwmon2/temp1_input";
        "critical-threshold"= 80;
        "format"= "{temperatureC}°C {icon}";
        "format-icons"= [
          ""
          ""
          ""
        ];
      };
      "power-profiles-daemon"= {
        "format"= "{icon}";
        "tooltip-format"= "Power profile: {profile}\nDriver: {driver}";
        "tooltip"= true;
        "format-icons"= {
          "default"= "";
          "performance"= "";
          "balanced"= "";
          "power-saver"= "";
        };
      };
      "network"= {
        "format-wifi"= "{essid} ({signalStrength}%) ";
        "format-ethernet"= "{ipaddr}/{cidr} 🖧";
        "tooltip-format"= "{ifname} via {gwaddr} 🖧";
        "format-linked"= "{ifname} (No IP)";
        "format-disconnected"= "Disconnected ⚠";
        "format-alt"= "{ifname}: {ipaddr}/{cidr}";
      };
      "pulseaudio"= {
        # "scroll-step"= 1; 
        "format"= "{volume}% {icon} {format_source}";
        "format-bluetooth"= "{volume}% {icon} {format_source}";
        "format-bluetooth-muted"= " {icon} {format_source}";
        "format-muted"= " {format_source}";
        "format-source"= "{volume}% ";
        "format-source-muted"= "";
        "format-icons"= {
          "headphone"= "";
          "hands-free"= "";
          "headset"= "";
          "phone"= "";
          "portable"= "";
          "car"= "";
          "default"= [
            ""
            ""
            ""
          ];
        };
        "on-click"= "pavucontrol";
      };
      "mpris"={
        "format" = "{player_icon} {dynamic}";
        "format-paused"="{player_icon} <i>{dynamic}</i>";
        "player-icons"= {
          "default"= "▶";
          "mpv"= "🎵";
        };
        "status-icons"= {
          "paused"= "⏸";
        };
      };
    };
  };
};
}
