#!/bin/bash
# Установка Node Exporter
set -e

NODE_VER="1.8.1"
NODE_USER="nodeusr"
NODE_DIR="/srv/node_exporter"

[ "$(id -u)" -ne 0 ] && SUDO="sudo" || SUDO=""

if ! id "$NODE_USER" &>/dev/null; then
  $SUDO useradd -r -s /usr/sbin/nologin "$NODE_USER"
  echo "Создан пользователь $NODE_USER"
fi

if [ ! -x "${NODE_DIR}/node_exporter" ]; then
  echo "Установка Node Exporter"
  $SUDO mkdir -p "$NODE_DIR"
  curl -sSL "https://github.com/prometheus/node_exporter/releases/download/v${NODE_VER}/node_exporter-${NODE_VER}.linux-amd64.tar.gz" \
    | $SUDO tar -xz --strip-components=1 -C "$NODE_DIR"
  $SUDO chown -R $NODE_USER:$NODE_USER "$NODE_DIR"
fi

cat <<EOF | $SUDO tee /etc/systemd/system/node_exporter.service >/dev/null
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=$NODE_USER
ExecStart=$NODE_DIR/node_exporter --web.listen-address=":9100"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

$SUDO systemctl daemon-reload
$SUDO systemctl enable --now node_exporter

echo "Node Exporter установлен и рабоатет на порту 9100"

