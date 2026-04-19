{ config, pkgs, ... }:

{
  imports = [
    ../modules/gaming.nix
  ];

  networking.hostName = "nixos-desktop";

  # Keep NVIDIA on the standard kernel track instead of the newest kernel ABI.
  boot.kernelPackages = pkgs.linuxPackages;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = false;
    nvidiaSettings = true;
  };

  systemd.services.set-default-power-profile = {
    description = "Set the default power profile";
    after = [ "power-profiles-daemon.service" ];
    wants = [ "power-profiles-daemon.service" ];
    wantedBy = [ "power-profiles-daemon.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
    '';
  };
}
