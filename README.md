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
