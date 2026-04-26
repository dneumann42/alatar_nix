{ config, lib, pkgs, ... }:

{
  options = {
    swayScripts.widescreenOnly = lib.mkOption {
      type = lib.types.path;
      description = "Path to widescreen-only script";
    };
  };

  config = {
    environment.systemPackages = [
      (pkgs.writeScriptBin "sway-widescreen-only" ''
        #!${pkgs.bash}/bin/bash
        ${lib.getExe pkgs.swaymsg} output "*" disable
        ${lib.getExe pkgs.swaymsg} output "DP-1" enable
      '')
    ];
  };
}