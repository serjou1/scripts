#!/usr/bin/env bash
set -e

LIB="/usr/local/lib/serjou"

help() {
  cat <<EOF
serjou — server toolset

Commands:
  install <tool>
  set <tool>
  update

Examples:
  serjou install docker
  serjou set loki --pm2
  serjou update
EOF
}

cmd="$1"
shift || true

case "$cmd" in
  ""|-h|--help)
    help
    ;;
  install)
    tool="$1"
    shift || true
    exec "$LIB/installers/$tool.sh" "$@"
    ;;
  set)
    tool="$1"
    shift || true
    exec "$LIB/set/$tool.sh" "$@"
    ;;
  update)
    exec bash -c 'curl -fsSL https://serjou.dev/install | bash'
    ;;
  *)
    echo "Unknown command: $cmd"
    help
    exit 1
    ;;
esac
