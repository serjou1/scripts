#!/usr/bin/env bash
set -e

BASE_URL="https://serjou.dev/scripts"
PREFIX="/usr/local"
LIB_DIR="$PREFIX/lib/serjou"
BIN_DIR="$PREFIX/bin"

MANIFEST_URL="$BASE_URL/internal/scripts_list.sh"
MANIFEST_PATH="$LIB_DIR/manifest.sh"

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

echo "[serjou] Done"
echo "Run: serjou -h"
