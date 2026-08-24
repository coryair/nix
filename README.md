# install
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh

omz reload

# confirm working state
nix-shell -p htop --run htop

# make directory for config files
mkdir nix
cd nix
nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"

# open config in vscode
code flake.nix

# use config to install
sudo nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/nix#macbook

# rebuild after adjusting config
sudo darwin-rebuild switch --flake ~/nix#macbook