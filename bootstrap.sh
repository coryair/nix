#!/bin/sh
set -eu

if [ "$#" -ne 0 ]; then
  echo "bootstrap.sh takes no arguments; it detects the current machine." >&2
  exit 1
fi

config_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)
runtime_dir=$(mktemp -d "${TMPDIR:-/tmp}/nix-bootstrap.XXXXXX")
runtime_dir=$(CDPATH='' cd -- "$runtime_dir" && pwd -P)
trap 'rm -rf "$runtime_dir"' EXIT

kernel=$(uname -s)
case "$kernel" in
  Darwin)
    platform=darwin
    output_name=darwinConfigurations
    ;;
  Linux)
    platform=linux
    output_name=homeConfigurations
    ;;
  *)
    echo "Unsupported operating system: $kernel" >&2
    exit 1
    ;;
esac

machine=$(uname -m)
case "$machine" in
  arm64 | aarch64) architecture=aarch64 ;;
  x86_64 | amd64) architecture=x86_64 ;;
  *)
    echo "Unsupported architecture: $machine" >&2
    exit 1
    ;;
esac

if [ "$(id -u)" -eq 0 ]; then
  echo "Run bootstrap.sh as your normal user. It requests sudo when needed." >&2
  exit 1
fi

user_name=$(id -un)
home_directory=${HOME:?HOME is not set}

if [ "$platform" = darwin ] && command -v scutil >/dev/null 2>&1; then
  host_name=$(scutil --get LocalHostName)
else
  host_name=$(hostname -s)
fi

validate_value() {
  label=$1
  value=$2

  if printf '%s' "$value" | LC_ALL=C grep -q '[^A-Za-z0-9._/@+ -]'; then
    echo "$label contains characters that cannot be written safely to the runtime Nix configuration." >&2
    exit 1
  fi
}

validate_value "Configuration path" "$config_dir"
validate_value "User name" "$user_name"
validate_value "Home directory" "$home_directory"
validate_value "Host name" "$host_name"

system="$architecture-$platform"
nix_path=$(command -v nix || true)

if [ -z "$nix_path" ] && [ -x /nix/var/nix/profiles/default/bin/nix ]; then
  nix_path=/nix/var/nix/profiles/default/bin/nix
fi

if [ -z "$nix_path" ]; then
  installer="$runtime_dir/nix-installer.sh"
  curl -fsSL https://nixos.org/nix/install -o "$installer"
  sh "$installer" --daemon
  nix_path=/nix/var/nix/profiles/default/bin/nix
fi

if [ ! -x "$nix_path" ]; then
  echo "Nix installation completed, but the nix executable was not found." >&2
  exit 1
fi

{
  printf '%s\n' '{'
  printf '  inputs.config.url = "path:%s";\n' "$config_dir"
  printf '%s\n' '  outputs = { config, ... }: {'
  printf '    %s.machine = config.lib.mkConfiguration {\n' "$output_name"
  printf '      system = "%s";\n' "$system"
  printf '      userName = "%s";\n' "$user_name"
  printf '      homeDirectory = "%s";\n' "$home_directory"
  printf '      hostName = "%s";\n' "$host_name"
  printf '%s\n' '    };' '  };' '}'
} > "$runtime_dir/flake.nix"

if [ "$platform" = darwin ]; then
  sudo -H "$nix_path" \
    --extra-experimental-features "nix-command flakes" \
    run "path:$config_dir" -- \
    switch --flake "path:$runtime_dir#machine"
else
  "$nix_path" \
    --extra-experimental-features "nix-command flakes" \
    run "path:$config_dir" -- \
    switch -b hm-backup --flake "path:$runtime_dir#machine"
fi
