{ pkgs, ... }:
{
  programs.zellij = {
    enable = true;
    settings = { };
  };

  xdg.configFile."zellij/config.kdl".text = ''
    copy_command "wl-copy"
    default_layout "compact"
    default_shell "${pkgs.fish}/bin/fish"
    hide_session_name true
    pane_frames false
    show_release_notes false
    show_startup_tips false
    simplified_ui true

    keybinds {
        shared_except "scroll" "locked" {
            bind "Ctrl s" { SwitchToMode "Scroll"; }
        }
        shared_except "normal" "locked" {
            bind "Enter" "Esc" { SwitchToMode "Normal"; }
        }
        scroll {
            bind "Ctrl s" "Esc" "q" { SwitchToMode "Normal"; }
            bind "j" "Down" { ScrollDown; }
            bind "k" "Up" { ScrollUp; }
            bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
            bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
            bind "d" { HalfPageScrollDown; }
            bind "u" { HalfPageScrollUp; }
            bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
        }
    }
  '';
}
