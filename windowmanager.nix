{ config, pkgs, ... }:
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
