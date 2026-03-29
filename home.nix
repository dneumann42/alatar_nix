{ config, pkgs, lib, ... }:

{
  home.stateVersion = "25.05";
  home.enableNixpkgsReleaseCheck = false;

  home.sessionPath = [
    "$HOME/.bun/bin"
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "$HOME/.npm-global/bin"
    "$HOME/.deno/bin"
    "$HOME/.local/share/pnpm"
    "$HOME/.nimble/bin"
  ];

  home.packages = with pkgs; [
    neovim
    bun
    gnome-tweaks
    nordic
    git
    foot
    grim
    slurp
    swaybg
    swayidle
    swaylock
    wl-clipboard
    wofi
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
  };

  programs.gnome-shell.enable = true;

  programs.gnome-shell.extensions = [
    { package = pkgs.gnomeExtensions.paperwm; }
    { package = pkgs.gnomeExtensions.user-themes; }
  ];

  programs.foot.enable = true;
  programs.swaylock.enable = true;
  programs.wofi.enable = true;
  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "sway/window" ];
        modules-right = [ "pulseaudio" "network" "clock" "tray" ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "󰎆";
            "5" = "";
            urgent = "";
            default = "";
          };
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
          };
        };

        clock = {
          format = "{:%a %b %d  %H:%M}";
          tooltip-format = "{:%Y-%m-%d}";
        };

        network = {
          format-wifi = "  {signalStrength}%";
          format-ethernet = "󰈀";
          format-disconnected = "󰖪";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
        };
      }
    ];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Symbols Nerd Font";
        font-size: 13px;
      }

      window#waybar {
        background: rgba(46, 52, 64, 0.94);
        color: #eceff4;
      }

      #workspaces {
        margin: 0 8px;
      }

      #workspaces button {
        padding: 0 10px;
        color: #88c0d0;
      }

      #workspaces button.focused {
        background: #5e81ac;
        color: #eceff4;
      }

      #window,
      #clock,
      #network,
      #pulseaudio,
      #tray {
        padding: 0 12px;
      }
    '';
  };

  services.mako = {
    enable = true;
    settings = {
      background-color = "#2E3440";
      border-color = "#88C0D0";
      text-color = "#ECEFF4";
      default-timeout = 5000;
    };
  };

  services.swayidle = {
    enable = true;
    systemdTarget = "sway-session.target";
    timeouts = [
      {
        timeout = 600;
        command = "${pkgs.swaylock}/bin/swaylock -fF";
      }
      {
        timeout = 900;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -fF";
      }
      {
        event = "lock";
        command = "${pkgs.swaylock}/bin/swaylock -fF";
      }
    ];
  };

  wayland.windowManager.sway = let
    defaultGap = 12;
  in {
    enable = true;
    systemd.enable = true;
    wrapperFeatures.gtk = true;
    extraConfig = ''
      gaps inner ${toString defaultGap}
    '';

    config = {
      workspaceAutoBackAndForth = true;
      modifier = "Mod4";
      terminal = "foot";
      menu = "wofi --show drun";

      bars = [
        {
          command = "waybar";
        }
      ];

      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
        workspaceBindings = lib.listToAttrs (
          builtins.concatLists (map
            (n: [
              {
                name = "${modifier}+${toString n}";
                value = "workspace number ${toString n}";
              }
              {
                name = "${modifier}+Shift+${toString n}";
                value = "move container to workspace number ${toString n}";
              }
            ])
            [ 1 2 3 4 5 6 7 8 9 ])
        );
      in workspaceBindings // {
        "${modifier}+0" = "workspace number 10";
        "${modifier}+Return" = "exec foot";
        "${modifier}+a" = "focus parent";
        "${modifier}+b" = "splith";
        "${modifier}+d" = "exec wofi --show drun";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+q" = "kill";
        "${modifier}+r" = "mode resize";
        "${modifier}+s" = "layout stacking";
        "${modifier}+space" = "focus mode_toggle";
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";
        "${modifier}+equal" = "gaps inner current plus 5";
        "${modifier}+minus" = "gaps inner current minus 5";
        "${modifier}+v" = "splitv";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+Shift+equal" = "gaps inner all set ${toString defaultGap}";
        "${modifier}+Shift+minus" = "scratchpad show";
        "${modifier}+Ctrl+h" = "resize shrink width 10 px";
        "${modifier}+Ctrl+j" = "resize grow height 10 px";
        "${modifier}+Ctrl+k" = "resize shrink height 10 px";
        "${modifier}+Ctrl+l" = "resize grow width 10 px";
        "${modifier}+Tab" = "workspace back_and_forth";
        "${modifier}+Shift+0" = "move container to workspace number 10";
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Exit Sway?' -B 'Yes' 'swaymsg exit'";
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";
        "${modifier}+Shift+BackSpace" = "move scratchpad";
        "${modifier}+Shift+r" = "restart";
        "${modifier}+Shift+space" = "floating toggle";
        "Print" = "exec grim -g \"$(slurp)\" - | wl-copy";
      };

      modes.resize = {
        Escape = "mode default";
        Return = "mode default";
        h = "resize shrink width 10 px";
        j = "resize grow height 10 px";
        k = "resize shrink height 10 px";
        l = "resize grow width 10 px";
        Left = "resize shrink width 10 px";
        Down = "resize grow height 10 px";
        Up = "resize shrink height 10 px";
        Right = "resize grow width 10 px";
      };

      startup = [
        { command = "mako"; }
      ];
    };
  };
}
