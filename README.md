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

### Updating nixpkgs

This repo uses flakes. `flake.nix` says `nixpkgs` follows
`github:NixOS/nixpkgs/nixos-unstable`, but the exact nixpkgs revision is pinned
in `flake.lock`. Rebuilding does not automatically move to the newest unstable.

To update the pinned nixpkgs revision:

```sh
rebuild-update
```

`rebuild-update` expands to `/etc/nixos/switch-host --update desktop`. It
updates only the `nixpkgs` input, runs a no-link preflight build, then switches
the desktop host. Use it when a package fix has landed in nixpkgs and the
current lockfile is still on an older broken revision.

## Proton VPN

The graphical Proton VPN client is installed as `proton-vpn`. It needs a Secret
Service provider, so the desktop config enables GNOME Keyring and Seahorse.

If login shows `We're sorry, an unexpected error occurred`, check:

```sh
tail -n 200 ~/.cache/Proton/VPN/logs/vpn-app.log
journalctl --user --since '30 minutes ago' | rg -i 'proton|keyring|secret|vpn'
```

Two known failure modes:

- `org.freedesktop.secrets was not provided`: GNOME Keyring is not running or
  the current session was started before the keyring config was applied. Rebuild
  and restart the graphical session or reboot.
- `ImportError: cannot import name 'Location' from 'proton.vpn.session.servers'`:
  nixpkgs packaged incompatible `proton-vpn` and `proton-vpn-api-core`
  versions. Update `flake.lock` after the nixpkgs fix reaches `nixos-unstable`.

## Proton Media

The desktop has a reproducible Proton Drive helper named `proton-media`.
It is generated from `home.nix`; do not hand-edit the installed script.

The fixed paths are:

- remote: `proton:Media`
- local: `~/.drive`
- rclone config: `~/.config/rclone/rclone.conf`

The rclone config contains Proton credentials and tokens, so it is intentionally
not stored in git. Everything else is in Nix.

### First setup

Apply the Nix config first:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#desktop
```

Create or verify the `proton` rclone remote:

```sh
proton-media setup
proton-media status
```

Download the remote `Media` folder into `~/.drive`:

```sh
proton-media download
```

`download` uses `rclone copy`, not `rclone sync`, so it downloads new and
changed remote files without deleting local-only files.

### Bidirectional sync

Only initialize bidirectional sync after `~/.drive` looks right.

Preview the first bisync:

```sh
proton-media dry-run
```

Initialize bisync:

```sh
proton-media init
```

The initial bisync prefers `proton:Media`, so the remote folder is treated as
the source of truth on first run.

After init, run normal bidirectional sync manually:

```sh
proton-media sync
```

Manual upload without bidirectional state is also available:

```sh
proton-media upload
```

### Automatic behavior

`proton-rclone-sync.timer` is intentionally download-only. It runs
`proton-media download`, so the unattended path does not upload local files or
delete remote files.

To check the timer:

```sh
systemctl --user status proton-rclone-sync.timer
```

To run the safe download job now:

```sh
systemctl --user start proton-rclone-sync.service
```

Bisync backups go to:

- local: `~/.drive/.rclone-backups/local`
- remote: `proton:.rclone-backups/Media`

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

To update nixpkgs before switching:

```sh
/etc/nixos/switch-host --update desktop
/etc/nixos/switch-host --update laptop
```

## Gaming

Gaming support is isolated in `modules/gaming.nix` and imported only by the
NVIDIA desktop host. The laptop profile does not load this module.

The gaming module enables:

- Steam
- Protontricks
- GE-Proton as an extra Steam compatibility tool
- Steam Remote Play firewall rules
- Steam Local Network Game Transfer firewall rules
- Steam's Gamescope session
- GameMode with renice support
- Gamescope with `CAP_SYS_NICE`
- MangoHud and Gamescope command-line tools

Apply gaming changes with the desktop rebuild:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#desktop
```

After rebuilding, useful checks are:

```sh
steam
gamemoded -s
gamescope --version
mangohud --version
```

For a per-game Steam launch option, use:

```text
gamemoderun mangohud %command%
```

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
