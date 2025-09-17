#!/bin/bash
# Установка Grafana
set -e

GRAF_VER="11.2.0"
GRAF_USER="grafana_usr"
GRAF_DIR="/srv/grafana"

[ "$(id -u)" -ne 0 ] && SUDO="sudo" || SUDO=""

if ! id "$GRAF_USER" &>/dev/null; then
  $SUDO useradd -r -s /usr/sbin/nologin "$GRAF_USER"
  echo "Cоздан пользователь $GRAF_USER"
fi

if [ ! -x "${GRAF_DIR}/bin/grafana-server" ]; then
  echo "Устанавливаю Grafana"
  $SUDO mkdir -p "$GRAF_DIR"
  curl -sSL "https://dl.grafana.com/oss/release/grafana-${GRAF_VER}.linux-amd64.tar.gz" \
    | $SUDO tar -xz --strip-components=1 -C "$GRAF_DIR"
  $SUDO chown -R $GRAF_USER:$GRAF_USER "$GRAF_DIR"
fi

$SUDO mkdir -p "$GRAF_DIR/conf/provisioning/datasources"
cat <<EOF | $SUDO tee "$GRAF_DIR/conf/provisioning/datasources/prometheus.yml" >/dev/null
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    url: http://localhost:9090
    access: proxy
    isDefault: true
EOF

cat <<EOF | $SUDO tee /etc/systemd/system/grafana.service >/dev/null
[Unit]
Description=Grafana
After=network.target

[Service]
User=$GRAF_USER
ExecStart=$GRAF_DIR/bin/grafana-server --homepath=$GRAF_DIR
Restart=always

[Install]
WantedBy=multi-user.target
EOF

$SUDO systemctl daemon-reload
$SUDO systemctl enable --now grafana

echo "Установил grafana и работает на 3000 порту"
