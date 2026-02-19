#!/usr/bin/env bash
set -e

BASE_URL="https://serjou.dev/scripts"
PREFIX="/usr/local"
LIB_DIR="$PREFIX/lib/serjou"
BIN_DIR="$PREFIX/bin"

MANIFEST_URL="$BASE_URL/internal/scripts_list.sh"
MANIFEST_PATH="$LIB_DIR/manifest.sh"
COMPLETION_PATH="$LIB_DIR/completion/serjou.bash"

echo "[serjou] Installing toolset"

# --- checks -------------------------------------------------

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "[serjou] Linux only"
  exit 1
fi

if [[ "$EUID" -ne 0 ]]; then
  echo "[serjou] Run as root"
  exit 1
fi

mkdir -p "$LIB_DIR"
mkdir -p "$BIN_DIR"

mkdir -p "$LIB_DIR" "$BIN_DIR"

echo "[serjou] Fetching manifest"
curl -fsSL "$MANIFEST_URL" -o "$MANIFEST_PATH"

# shellcheck source=/dev/null
source "$MANIFEST_PATH"

# --- install CLI -------------------------------------------

echo "[serjou] Installing CLI"

for entry in "${CLI_COMMANDS[@]}"; do
  name="${entry%%:*}"
  path="${entry##*:}"

  echo "  → $name"
  curl -fsSL "$BASE_URL/$path" -o "$BIN_DIR/$name"
  chmod +x "$BIN_DIR/$name"
done

# --- install installers ------------------------------------

echo "[serjou] Installing installers"

for entry in "${INSTALLERS[@]}"; do
  name="${entry%%:*}"
  path="${entry##*:}"

  target="$LIB_DIR/$path"
  mkdir -p "$(dirname "$target")"

  echo "  → $name"
  curl -fsSL "$BASE_URL/$path" -o "$target"
  chmod +x "$target"
done

# --- install set commands ----------------------------------

echo "[serjou] Installing set commands"

for entry in "${SET_COMMANDS[@]}"; do
  name="${entry%%:*}"
  path="${entry##*:}"

  target="$LIB_DIR/$path"
  mkdir -p "$(dirname "$target")"

  echo "  → $name"
  curl -fsSL "$BASE_URL/$path" -o "$target"
  chmod +x "$target"
done

# --- install completion ------------------------------------

echo "[serjou] Installing completion"
mkdir -p "$(dirname "$COMPLETION_PATH")"
curl -fsSL "$BASE_URL/completion/serjou.bash" -o "$COMPLETION_PATH"

append_source_if_missing() {
  local rc_file="$1"
  local source_line='[[ -r "/usr/local/lib/serjou/completion/serjou.bash" ]] && source "/usr/local/lib/serjou/completion/serjou.bash"'

  [[ -f "$rc_file" ]] || return 0
  grep -Fq "$source_line" "$rc_file" || echo "$source_line" >> "$rc_file"
}

append_source_if_missing "/etc/bash.bashrc"
append_source_if_missing "/etc/zsh/zshrc"

echo "[serjou] Done"
echo "Run: serjou -h"
