{ pkgs, ... }:
{
home.packages = with pkgs; [
    waybar-mpris
  ];
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
      colors = {
        alpha="0.8";
      }; 
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;

    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    # as per Hyprland Wiki https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/
    package = null;
    portalPackage = null;

    settings = {
      # internal Hyprland vars
      "$fileManager" = "${pkgs.yazi}/bin/yazi";
      "$menu" = "${pkgs.wofi}/bin/wofi --show drun";
      "$terminal" = "${pkgs.foot}/bin/foot";
      "$mod" = "MOD4";
      "$rightMon" = "HDMI-A-1";
      "$leftMon" = "HDMI-A-2";
      
      monitor = [
        "$rightMon, 3840x2160@120, 0x0, 1,vrr,1"
        "$leftMon, 3840x2160, -3840x0, 1"
      ];

      workspace = builtins.concatLists (builtins.genList (i:
      let 
        ls = toString (2*i+2); 
        rs = toString (2*i+1); 
      in [
        "${ls}, monitor:$leftMon"
        "${rs}, monitor:$rightMon"
      ]) 5 );

      exec-once = [
        #"${pkgs.waybar}/bin/waybar &" # evidently this loads automatically? let's find out.
        "${pkgs.hyprpaper}/bin/hyprpaper &"
        "${pkgs.waybar}/bin/waybar"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORMTHEME,qt5ct" # change to qt6ct if you have that
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
          pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          "preserve_split" = true; # you probably want this;
      };
      
      gestures = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          workspace_swipe = "off";
      };
      
      misc = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          force_default_wallpaper = 0; # Set to 0 or 1 to disable the anime mascot wallpapers
          # vrr = 1
      };
      
      windowrulev2 = "suppressevent maximize, class:.*"; # You'll probably like this.


      "$mainMod" = "MOD4";
      bind = [
        "$mainMod, Return, exec, $terminal"
        "$mainMod, Q, killactive, "
        "$mainMod, E, exit, "
        "$mainMod, F, exec, $terminal $fileManager"
        "$mainMod, V, togglefloating, "
        "$mainMod, D, exec, $menu"
        "$mainMod, P, pseudo, " # dwindle
        "$mainMod, C, togglesplit, " # dwindle

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
          "*"
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
        # "icon-size"= 21;
        "spacing"= 10;
      };
      "clock"= {
        # "timezone"= "America/New_York";
        "tooltip-format"= "<big>{=%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        "format-alt"= "{=%Y-%m-%d}";
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
