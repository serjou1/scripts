#!/bin/bash
# loki.sh — setup Promtail to collect PM2 logs and push to Loki
# Usage: ./loki.sh Server-01

set -e

# Check for job name
if [ -z "$1" ]; then
  echo "Usage: $0 <job_name>"
  exit 1
fi

JOB_NAME="$1"

# Paths
PROMTAIL_CONFIG="./promtail-config.yaml"
PM2_LOG_DIR="$HOME/.pm2/logs"
POSITION_FILE="/tmp/positions.yaml"

# Loki endpoint
LOKI_URL="https://loki.serjou.dev/loki/api/v1/push"

# Create Promtail config
cat > "$PROMTAIL_CONFIG" <<EOF
server:
  http_listen_port: 9080
  grpc_listen_port: 0
  log_level: debug

positions:
  filename: $POSITION_FILE

clients:
  - url: $LOKI_URL

scrape_configs:
  - job_name: $JOB_NAME
    static_configs:
      - targets:
          - localhost
        labels:
          job: $JOB_NAME
          __path__: $PM2_LOG_DIR/*.log
EOF

echo "✅ Promtail config created at $PROMTAIL_CONFIG with job name: $JOB_NAME"

# Check if docker-compose service exists
if ! docker-compose ps promtail &>/dev/null; then
  echo "ℹ️  Promtail service not found in docker-compose. Starting..."
  docker-compose up -d promtail
else
  echo "ℹ️  Promtail service already exists, restarting..."
  docker-compose restart promtail
fi

echo "🎉 Promtail is running and collecting logs from $PM2_LOG_DIR under job: $JOB_NAME"
