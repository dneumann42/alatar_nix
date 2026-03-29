{ pkgs, ... }:

{
  services.displayManager.ly = {
    enable = true;
    x11Support = false;
    settings = {
      animation = "colormix";
      animation_timeout_sec = 300;
      bigclock = "en";
      bg = "0x02000000";
      border_fg = "0x0188C0D0";
      clear_password = true;
      clock = "%A, %b %d  %H:%M";
      colormix_col1 = "0x0881A1C1";
      colormix_col2 = "0x0888C0D0";
      colormix_col3 = "0x085E81AC";
      default_input = "password";
      error_fg = "0x01BF616A";
      fg = "0x01ECEFF4";
      hide_borders = false;
      hide_key_hints = false;
      hide_version_string = true;
      load = true;
      save = true;
    };
  };

  hardware.graphics.enable = true;

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleSuspendKey = "suspend";
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  programs.ssh.systemd-ssh-proxy.enable = false;

  security.polkit.enable = true;
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  systemd.services.flatpak-flathub = {
    description = "Add the Flathub Flatpak remote";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "flatpak-system-helper.service" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    serviceConfig.Type = "oneshot";
    script = ''
      flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  systemd.services.flatpak-waterfox = {
    description = "Install the Waterfox Flatpak";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "flatpak-system-helper.service" "flatpak-flathub.service" ];
    wants = [ "network-online.target" "flatpak-flathub.service" ];
    path = [ pkgs.flatpak ];
    serviceConfig.Type = "oneshot";
    script = ''
      flatpak install --system --noninteractive --or-update flathub net.waterfox.waterfox
    '';
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    power-profiles-daemon
  ];
}
