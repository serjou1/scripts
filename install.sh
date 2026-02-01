#!/usr/bin/env bash
set -e

BASE_URL="https://serjou.dev/scripts"
PREFIX="/usr/local"
LIB_DIR="$PREFIX/lib/serjou"
BIN_DIR="$PREFIX/bin"

MANIFEST_URL="$BASE_URL/internal/scripts_list.yml"

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

# --- download manifest -------------------------------------

echo "[serjou] Fetching manifest"
MANIFEST="$(curl -fsSL "$MANIFEST_URL")"

# --- helper to parse yaml (VERY minimal, intentional) ------

get_entries() {
  local section="$1"
  echo "$MANIFEST" \
    | awk "/^$section:/{flag=1;next}/^[^ ]/{flag=0}flag" \
    | sed 's/^  //' \
    | sed 's/:/ /' \
    | awk 'NF == 2'
}


# --- install CLI -------------------------------------------

echo "[serjou] Installing CLI"

while read -r name path; do
  echo "installing $BASE_URL/$path"
  curl -fsSL "$BASE_URL/$path" -o "$BIN_DIR/$name"
  chmod +x "$BIN_DIR/$name"
done < <(get_entries cli)

# --- install installers ------------------------------------

echo "[serjou] Installing installers"

while read -r name path; do
  target="$LIB_DIR/$path"
  mkdir -p "$(dirname "$target")"
  curl -fsSL "$BASE_URL/$path" -o "$target"
  chmod +x "$target"
done < <(get_entries installers)

# --- install set commands ----------------------------------

echo "[serjou] Installing set commands"

while read -r name path; do
  target="$LIB_DIR/$path"
  mkdir -p "$(dirname "$target")"
  curl -fsSL "$BASE_URL/$path" -o "$target"
  chmod +x "$target"
done < <(get_entries set)

echo "[serjou] Done"
echo "Run: serjou -h"
