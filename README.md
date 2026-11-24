# install
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh

omz reload

# confirm working state
nix-shell -p htop --run htop

# clone config
git clone https://github.com/coryair/nix.git ~/nix
cd ~/nix

# use config to install
sudo nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/nix#macbook

# rebuild after adjusting config
sudo darwin-rebuild switch --flake ~/nix#macbook

# Set up another Mac using an external drive

Use the drive to transfer this repository; install Nix separately on the other
Mac. Internet access is required to download packages and apps. The current
configuration expects an Apple Silicon Mac and the username `cory.hernandez`.
Adjust the username, home paths, and platform in `flake.nix` before applying it
if the other Mac differs.

Copy the entire repository to the external drive, including hidden files such
as `.config` and `.git`. For a drive named `SSD`, with no existing `nix` folder:

```sh
ditto ~/nix /Volumes/SSD/nix
```

On the other Mac, copy it into `~/nix` (start with no existing `~/nix` folder):

```sh
ditto /Volumes/SSD/nix ~/nix
```

Keep the repository at `~/nix`: Home Manager links configuration files from
`~/nix/.config`. Replace `/Volumes/SSD` with your drive's mounted path if needed.

Install Nix on the other Mac:

```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
```

Open a new Terminal window, then apply the configuration:

```sh
sudo nix run nix-darwin \
  --extra-experimental-features "nix-command flakes" \
  -- switch --flake ~/nix#macbook
```

This installs the configured apps and applies macOS and user settings. The
Homebrew configuration also removes unmanaged Homebrew packages during
activation, so review it first if the other Mac already uses Homebrew. Sign into
apps and grant macOS permissions as needed. Once copied, the external drive is
not required for normal use.

# Codex CLI

Codex is installed through the Homebrew cask declared in `flake.nix`. System
rebuilds update it through Homebrew. Nix still manages the Codex settings and hooks.

To update manually:

```sh
brew update
brew upgrade --cask codex
```

# quick reminders

Hold Caps Lock and press R to open Apple Reminders. Press Caps+R again to
return to the previous app, matching the Caps+T terminal and Caps+S Slack toggles.
In Reminders, press Command+N, type a task, and press Return to save it.
Check tasks off when done; View > Show Completed displays their history.

The shortcut is managed in `.config/karabiner/karabiner.json` through Home Manager.
After editing, verify `~/.config/karabiner/karabiner.json` resolves to the repository
file, then restart Karabiner from its Quit, Restart settings to reload it.
Avoid `karabiner_cli --select-profile`, which can replace the managed symlink.
