#!/usr/bin/env bash
set -e

BASE_URL="https://serjou.dev/scripts"

GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m"

log() {
  echo -e "${GREEN}[serjou]${NC} $1"
}

log "Starting installation..."