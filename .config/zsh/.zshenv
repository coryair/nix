# rustup (installed outside nix): put ~/.cargo/bin on PATH for every zsh,
# including non-interactive shells. Skipped on machines without rustup.
[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
