#!/bin/bash
# Установка Prometheus
set -e

PROM_VER="2.54.0"
PROM_USER="prometheus_usr"
PROM_DIR="/srv/prometheus"
PROM_DATA="${PROM_DIR}/data"
PROM_CFG="${PROM_DIR}/prometheus.yml"

[ "$(id -u)" -ne 0 ] && SUDO="sudo" || SUDO=""

if ! id "$PROM_USER" &>/dev/null; then
  $SUDO useradd -r -s /usr/sbin/nologin "$PROM_USER"
  echo "Cоздан пользователь $PROM_USER"
fi

if [ ! -x "${PROM_DIR}/prometheus" ]; then
  echo "Устанавливаю Prometheus"
  $SUDO mkdir -p "$PROM_DIR" "$PROM_DATA"
  curl -sSL "https://github.com/prometheus/prometheus/releases/download/v${PROM_VER}/prometheus-${PROM_VER}.linux-amd64.tar.gz" \
    | $SUDO tar -xz --strip-components=1 -C "$PROM_DIR"
  $SUDO chown -R $PROM_USER:$PROM_USER "$PROM_DIR"
fi

if [ ! -f "$PROM_CFG" ]; then
  cat <<EOF | $SUDO tee "$PROM_CFG" >/dev/null
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
EOF
  $SUDO chown $PROM_USER:$PROM_USER "$PROM_CFG"
fi

cat <<EOF | $SUDO tee /etc/systemd/system/prometheus.service >/dev/null
[Unit]
Description=Prometheus
After=network.target

[Service]
User=$PROM_USER
ExecStart=$PROM_DIR/prometheus \
  --config.file=$PROM_CFG \
  --storage.tsdb.path=$PROM_DATA \
  --storage.tsdb.retention.size=10GB \
  --storage.tsdb.retention.time=15d
Restart=always

[Install]
WantedBy=multi-user.target
EOF

$SUDO systemctl daemon-reload
$SUDO systemctl enable --now prometheus

echo "Прометеус установлен и работает на порту 9090"

