#!/bin/sh
# shellcheck disable=SC2016
set -eu

repo_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/bootstrap-test.XXXXXX")
work_dir=$(CDPATH='' cd -- "$work_dir" && pwd -P)
trap 'rm -rf "$work_dir"' EXIT

mkdir -p "$work_dir/bin" "$work_dir/config" "$work_dir/home" "$work_dir/captures"
cp "$repo_dir/bootstrap.sh" "$work_dir/config/bootstrap.sh"

printf '%s\n' '#!/bin/sh' 'case "$1" in' \
  '  -s) echo "$TEST_KERNEL" ;;' \
  '  -m) echo "$TEST_ARCH" ;;' \
  '  *) exit 1 ;;' \
  'esac' > "$work_dir/bin/uname"

printf '%s\n' '#!/bin/sh' 'case "$1" in' \
  '  -u) echo 1000 ;;' \
  '  -un) echo cory ;;' \
  '  *) exit 1 ;;' \
  'esac' > "$work_dir/bin/id"

printf '%s\n' '#!/bin/sh' 'echo test-host' > "$work_dir/bin/hostname"
printf '%s\n' '#!/bin/sh' 'echo test-host' > "$work_dir/bin/scutil"

printf '%s\n' '#!/bin/sh' \
  'mkdir -p "$TEST_RUNTIME_DIR"' \
  'echo "$TEST_RUNTIME_DIR"' > "$work_dir/bin/mktemp"

printf '%s\n' '#!/bin/sh' \
  'printf "%s\n" "$*" > "$TEST_CAPTURE_DIR/curl-args"' \
  'while [ "$#" -gt 0 ]; do' \
  '  if [ "$1" = "-o" ]; then' \
  '    shift' \
  '    : > "$1"' \
  '  fi' \
  '  shift' \
  'done' > "$work_dir/bin/curl"

printf '%s\n' '#!/bin/sh' \
  'printf "%s\n" "$*" > "$TEST_CAPTURE_DIR/installer-args"' \
  "cp '$work_dir/nix-template' '$work_dir/installed-nix'" \
  "chmod +x '$work_dir/installed-nix'" > "$work_dir/bin/sh"

printf '%s\n' '#!/bin/sh' \
  'if [ "${1:-}" != "-H" ]; then' \
  '  echo "warning: \$HOME (\x27$HOME\x27) is not owned by you" >&2' \
  '  exit 1' \
  'fi' \
  'shift' \
  'echo "$TEST_KERNEL" >> "$TEST_CAPTURE_DIR/sudo-calls"' \
  'exec "$@"' > "$work_dir/bin/sudo"

printf '%s\n' '#!/bin/sh' \
  'if [ "$TEST_KERNEL" = "Darwin" ] && printf "%s" "$*" | grep -q -- "--flake /"; then' \
  '  echo "error: \x27$TEST_RUNTIME_DIR#darwinConfigurations.machine.system\x27 is not a valid URL" >&2' \
  '  exit 1' \
  'fi' \
  'cp "$TEST_RUNTIME_DIR/flake.nix" "$TEST_CAPTURE_DIR/$TEST_KERNEL-flake.nix"' \
  'printf "%s\n" "$*" > "$TEST_CAPTURE_DIR/$TEST_KERNEL-args"' > "$work_dir/nix-template"

chmod +x "$work_dir/config/bootstrap.sh" "$work_dir/bin/"* "$work_dir/nix-template"

sed \
  -e "s|/nix/var/nix/profiles/default/bin/nix|$work_dir/installed-nix|g" \
  "$work_dir/config/bootstrap.sh" > "$work_dir/bootstrap.sh"
chmod +x "$work_dir/bootstrap.sh"
ln -s "$work_dir" "$work_dir/config-link"

TEST_KERNEL=Darwin \
TEST_ARCH=arm64 \
TEST_RUNTIME_DIR="$work_dir/config-link/runtime" \
TEST_CAPTURE_DIR="$work_dir/captures" \
HOME="$work_dir/home" \
PATH="$work_dir/bin:/usr/bin:/bin" \
  "$work_dir/config-link/bootstrap.sh"

grep -F 'https://nixos.org/nix/install' "$work_dir/captures/curl-args" >/dev/null
grep -F -- '--daemon' "$work_dir/captures/installer-args" >/dev/null
grep -F "run path:$work_dir -- switch --flake path:$work_dir/runtime#machine" \
  "$work_dir/captures/Darwin-args" >/dev/null
grep -F 'darwinConfigurations.machine' "$work_dir/captures/Darwin-flake.nix" >/dev/null
grep -F 'system = "aarch64-darwin";' "$work_dir/captures/Darwin-flake.nix" >/dev/null
grep -F 'userName = "cory";' "$work_dir/captures/Darwin-flake.nix" >/dev/null
grep -F "homeDirectory = \"$work_dir/home\";" "$work_dir/captures/Darwin-flake.nix" >/dev/null
grep -F 'hostName = "test-host";' "$work_dir/captures/Darwin-flake.nix" >/dev/null
grep -F 'Darwin' "$work_dir/captures/sudo-calls" >/dev/null

printf '%s\n' '#!/bin/sh' 'exit 99' > "$work_dir/bin/curl"

TEST_KERNEL=Linux \
TEST_ARCH=x86_64 \
TEST_RUNTIME_DIR="$work_dir/config-link/runtime" \
TEST_CAPTURE_DIR="$work_dir/captures" \
HOME="$work_dir/home" \
PATH="$work_dir/bin:/usr/bin:/bin" \
  "$work_dir/config-link/bootstrap.sh"

grep -F "run path:$work_dir -- switch -b hm-backup --flake path:$work_dir/runtime#machine" \
  "$work_dir/captures/Linux-args" >/dev/null
grep -F 'homeConfigurations.machine' "$work_dir/captures/Linux-flake.nix" >/dev/null
grep -F 'system = "x86_64-linux";' "$work_dir/captures/Linux-flake.nix" >/dev/null

if grep -F 'Linux' "$work_dir/captures/sudo-calls" >/dev/null; then
  echo "Linux Home Manager activation must not run through sudo." >&2
  exit 1
fi
