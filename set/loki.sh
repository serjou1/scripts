#!/usr/bin/env bash
set -e

PROMTAIL_DIR="$HOME/serjou-loki"
mkdir -p "$PROMTAIL_DIR"

# defaults
pm2=false
job_name="system"

# parse flags
while [[ $# -gt 0 ]]; do
    case $1 in
        --pm2) pm2=true; shift ;;
        --job_name) job_name="$2"; shift 2 ;;
        *) echo "[serjou] Unknown flag $1"; exit 1 ;;
    esac
done

echo "[serjou] pm2 enabled: $pm2"
echo "[serjou] job_name: $job_name"

# generate promtail config
cat > "$PROMTAIL_DIR/promtail-config.yaml" <<EOF
server:
  log_level: debug
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: https://loki.serjou.dev/loki/api/v1/push

scrape_configs:
- job_name: system
  static_configs:
  - targets:
      - "localhost"
    labels:
      job: "$job_name"
      __path__: "/root/.pm2/logs/*.log"
EOF

# generate docker-compose.yml
cat > "$PROMTAIL_DIR/docker-compose.yml" <<EOF
version: '3'
services:
  promtail:
    image: grafana/promtail:latest
    container_name: promtail
    volumes:
      - $PROMTAIL_DIR/promtail-config.yaml:/etc/promtail/config.yml
      - /var/log:/var/log
      - /root/.pm2/logs:/root/.pm2/logs
    command: -config.file=/etc/promtail/config.yml
EOF

# start/restart promtail
cd "$PROMTAIL_DIR"
if docker ps -a --format '{{.Names}}' | grep -q '^promtail$'; then
    docker compose down
fi

docker compose up -d

echo "[serjou] promtail started with job_name=$job_name"
