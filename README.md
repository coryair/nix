# Nix-managed machine guide

Declarative macOS and Linux configuration built with Nix, nix-darwin, and Home Manager.

- macOS: nix-darwin manages the system and Home Manager manages the user environment.
- Linux: Home Manager manages the user environment.
- `bootstrap.sh` detects the operating system, architecture, user, home directory, and hostname.

Run commands in this README as your normal user. The bootstrap script requests `sudo` on macOS when needed.

## Fresh machine

Clone the configuration into its expected location and apply it:

```sh
git clone git@github.com:coryair/nix.git ~/.config/nix-darwin
cd ~/.config/nix-darwin
./bootstrap.sh
exec zsh -l
```

`bootstrap.sh` installs upstream Nix in daemon mode when Nix is missing. It then applies nix-darwin and Home Manager on macOS, or Home Manager on Linux.

If the directory was copied instead of cloned, start with:

```sh
cd ~/.config/nix-darwin
./bootstrap.sh
exec zsh -l
```

Do not pass a machine name to `bootstrap.sh`.

## Existing managed machine

Update a Git checkout and apply it:

```sh
cd ~/.config/nix-darwin
git status --short
git pull --ff-only
./bootstrap.sh
exec zsh -l
```

If the directory is not a Git checkout, copy the updated files into it and run the last two commands.

After editing the configuration locally:

```sh
cd ~/.config/nix-darwin
git diff
nix flake check --no-build
./bootstrap.sh
```

Use `./bootstrap.sh` to apply this repository. The flake detects the current machine at runtime, so it does not expose a fixed hostname for `darwin-rebuild switch --flake .`.

## Confirm the machine and Nix installation

```sh
uname -s
uname -m
id -un
hostname -s
command -v nix
nix --version
nix config show experimental-features
nix store info --store daemon
```

If `nix-command` or `flakes` is not enabled yet, add the features to a single command:

```sh
nix --extra-experimental-features "nix-command flakes" flake show
```

The managed configuration enables both features after the first successful bootstrap.

## Find the active configuration

On macOS:

```sh
readlink /run/current-system
darwin-rebuild --list-generations
nix path-info --closure-size --human-readable /run/current-system
```

For the Home Manager environment on either platform:

```sh
home-manager generations
home-manager packages
readlink ~/.local/state/nix/profiles/home-manager
```

Useful locations:

| Path | Purpose |
| --- | --- |
| `~/.config/nix-darwin` | Editable configuration checkout |
| `/run/current-system` | Active nix-darwin system on macOS |
| `~/.local/state/nix/profiles/home-manager` | Active Home Manager generation |
| `/nix/store` | Immutable packages and configuration results |
| `/etc/nix/nix.conf` | Active system Nix settings |

Do not edit files in `/nix/store`. Change the Nix configuration and rebuild instead.

## Inspect the flake

Run these commands from `~/.config/nix-darwin`:

```sh
nix flake metadata
nix flake show
nix flake check --no-build
```

See what changed in the lock file before applying dependency updates:

```sh
git diff flake.lock
```

Update every pinned input deliberately:

```sh
nix flake update
git diff flake.lock
nix flake check --no-build
./bootstrap.sh
```

## Find and try packages

Search nixpkgs:

```sh
nix search nixpkgs ripgrep
```

Open a temporary shell without adding a package to the configuration:

```sh
nix shell nixpkgs#jq
```

Run one command in a temporary shell:

```sh
nix shell nixpkgs#jq --command jq --version
```

Run an application directly:

```sh
nix run nixpkgs#cowsay -- hello
```

Show the store path and closure size of a package:

```sh
nix path-info nixpkgs#ripgrep
nix path-info --recursive --closure-size --human-readable nixpkgs#ripgrep
```

To keep a package, add it to `home.nix` for the user environment or `configuration.nix` for the macOS system, then run `./bootstrap.sh`.

## Understand dependencies and disk usage

Show the macOS system closure, sorted by size:

```sh
nix path-info --recursive --closure-size /run/current-system | sort -nk2
```

Explain why a package is included in the macOS system:

```sh
nix why-depends /run/current-system nixpkgs#firefox
```

Preview unreachable store paths without deleting them:

```sh
nix store gc --dry-run
```

After reviewing the preview, delete unreachable paths:

```sh
nix store gc
```

Old generations keep their referenced store paths alive. Remove generations only when their rollback points are no longer needed.

## Roll back

List and roll back the macOS system:

```sh
darwin-rebuild --list-generations
sudo darwin-rebuild --rollback
```

List and roll back the Home Manager environment:

```sh
home-manager generations
home-manager switch --rollback
```

After diagnosing a bad change, fix the configuration so the next `./bootstrap.sh` does not reintroduce it.

## Troubleshoot

Check Nix configuration and daemon access:

```sh
nix config check
nix store info --store daemon
```

Inspect the Nix daemon on macOS:

```sh
launchctl print system/org.nixos.nix-daemon
```

Inspect the Nix daemon on a systemd Linux machine:

```sh
systemctl status nix-daemon
```

Show a failed build log when Nix reports a store path:

```sh
nix log /nix/store/replace-with-the-reported-path
```

If a newly installed command is missing, start a new login shell and inspect the result:

```sh
exec zsh -l
type -a nix darwin-rebuild home-manager
```

## Repository map

| File | Purpose |
| --- | --- |
| `bootstrap.sh` | Detects and applies the current machine |
| `flake.nix` | Pins inputs and builds macOS or Linux outputs |
| `flake.lock` | Records exact dependency revisions |
| `configuration.nix` | macOS system settings and packages |
| `home.nix` | Cross-platform user packages and shell configuration |
| `tests/bootstrap-test.sh` | Exercises fresh macOS and existing Linux bootstrap paths |

## Validate the bootstrap script

```sh
sh -n bootstrap.sh tests/bootstrap-test.sh
sh tests/bootstrap-test.sh
git diff --check
```
