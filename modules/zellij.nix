{ pkgs, ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      simplified_ui = true;
      pane_frames = false;
      default_layout = "compact";
      default_shell = "${pkgs.fish}/bin/fish";
      copy_command = "wl-copy";
      show_startup_tips = false;
      show_release_notes = false;
      hide_session_name = true;
    };
  };
}
