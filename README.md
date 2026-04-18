# alatar_nix

NixOS configuration for my desktop and laptop systems.

## Install After The Graphical Installer

Use the NixOS graphical installer first. Create the user `dneumann`, finish the
install, reboot, and sign in as `dneumann`.

Open a terminal and run:

```sh
nix-shell -p git --run 'tmp=$(mktemp -d) && git clone https://github.com/dneumann42/alatar_nix "$tmp/alatar_nix" && "$tmp/alatar_nix/bootstrap-after-installer" desktop'
```

The script will:

- preserve `/etc/nixos/hardware-configuration.nix`
- archive the graphical installer's config to `/etc/nixos.backup-YYYYMMDD-HHMMSS`
- copy the git checkout to `/etc/nixos`
- restore `hardware-configuration.nix`
- run `sudo nixos-rebuild switch --flake /etc/nixos#desktop`

For the laptop host, use:

```sh
nix-shell -p git --run 'tmp=$(mktemp -d) && git clone https://github.com/dneumann42/alatar_nix "$tmp/alatar_nix" && "$tmp/alatar_nix/bootstrap-after-installer" laptop'
```

## Rebuild

After bootstrap, the real git checkout lives at `/etc/nixos`.

```sh
cd /etc/nixos
sudo git pull
sudo nixos-rebuild switch --flake /etc/nixos#desktop
```

The fish abbreviation `rebuild` runs the desktop rebuild command.

## Hosts

- `desktop`: NVIDIA desktop
- `desktop-nvidia`: alias for `desktop`
- `laptop`: laptop

Switch hosts with:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#desktop
sudo nixos-rebuild switch --flake /etc/nixos#laptop
```

The `switch-host` helper also accepts `desktop` or `laptop` and runs the
matching flake rebuild.

## Recovery

The bootstrap script archives the graphical installer's generated config before
replacing `/etc/nixos`. If the new config does not work, boot into an older
generation from the boot menu or a TTY, then inspect the backup:

```sh
ls -d /etc/nixos.backup-*
```

To restore the previous generated config manually:

```sh
sudo mv /etc/nixos /etc/nixos.failed
sudo mv /etc/nixos.backup-YYYYMMDD-HHMMSS /etc/nixos
sudo nixos-rebuild switch
```
