#!/usr/bin/env bash
set -e

LIB="/usr/local/lib/serjou"

help() {
  cat <<EOF
serjou — server toolset

Commands:
  install <tool>
  set <tool>

Examples:
  serjou install docker
  serjou set loki --pm2
EOF
}

cmd="$1"
shift || true

case "$cmd" in
  ""|-h|--help)
    help
    ;;
  install)
    exec "$LIB/installers/$1.sh" "$@"
    ;;
  set)
    exec "$LIB/set/$1.sh" "$@"
    ;;
  *)
    echo "Unknown command: $cmd"
    help
    exit 1
    ;;
esac
