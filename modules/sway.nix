{ setWallpaper }:
{ config, lib, pkgs, ... }:

let
  defaultGap = 12;
in
{
  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    wrapperFeatures.gtk = true;
    extraConfig = ''
      gaps inner ${toString defaultGap}
    '';

    config = {
      workspaceAutoBackAndForth = true;
      modifier = "Mod4";
      terminal = "ghostty";
      menu = "rofi -show drun";
      input = {
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
          scroll_method = "two_finger";
          click_method = "clickfinger";
          dwt = "enabled";
        };
      };

      window.commands = [
        {
          criteria.title = "termusic";
          command = "floating enable, resize set 1200 800";
        }
        {
          criteria.title = "toggle-ghostty";
          command = "floating enable, resize set 1400 900, move position center";
        }
        {
          criteria.title = "floating-terminal";
          command = "floating enable, resize set 1200 800, move position center";
        }
      ];

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
        "${modifier}+Return" = "exec ghostty";
        "${modifier}+Shift+Return" = "exec /etc/nixos/scripts/toggle-ghostty";
        "${modifier}+a" = "focus parent";
        "${modifier}+b" = "splith";
        "${modifier}+d" = "exec rofi -show drun";
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
        "${modifier}+m" = "exec ghostty --title=termusic -e termusic";
        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";
        "${modifier}+Ctrl+equal" = "gaps inner current plus 5";
        "${modifier}+minus" = "scratchpad show";
        "${modifier}+Ctrl+minus" = "gaps inner current minus 5";
        "${modifier}+v" = "splitv";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+Shift+equal" = "gaps inner all set ${toString defaultGap}";
        "${modifier}+Shift+minus" = "move scratchpad";
        "${modifier}+Shift+underscore" = "move scratchpad";
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
        { command = "blueman-applet"; }
        { command = "${setWallpaper}/bin/set-wallpaper"; }
      ];
    };
  };
}
