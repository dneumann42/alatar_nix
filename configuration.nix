{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./common-desktop.nix
      ./host.nix
      <home-manager/nixos>
    ];

  programs.fish.enable = true;
  home-manager.users.dneumann = import ./home.nix;
  home-manager.backupFileExtension = "backup";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.printing.enable = true;
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  users.users.dneumann = {
    isNormalUser = true;
    description = "dneumann";
    extraGroups = [ "networkmanager" "wheel" "input" "podman" ];
    packages = with pkgs; [];
  };

  users.defaultUserShell = pkgs.fish;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    gcc
    pavucontrol
    podman-compose
  ];

  system.stateVersion = "25.11";
}
