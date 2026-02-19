# shellcheck shell=bash
# Auto-generated / maintained manifest

CLI_COMMANDS=(
  serjou:serjou.sh
)

INSTALLERS=(
  docker:installers/docker.sh
  go:installers/go.sh
  git:installers/git.sh
)

SET_COMMANDS=(
  loki:set/loki.sh
)

# optional per-command flags (future-proof)
SET_FLAGS_loki=(
  --pm2
)
