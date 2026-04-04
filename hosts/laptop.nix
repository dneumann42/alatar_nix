{ pkgs, ... }:

{
  networking.hostName = "nixos";

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
  };

  systemd.services.set-default-power-profile = {
    description = "Set the default power profile";
    after = [ "power-profiles-daemon.service" ];
    wants = [ "power-profiles-daemon.service" ];
    wantedBy = [ "power-profiles-daemon.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver
    '';
  };
}
