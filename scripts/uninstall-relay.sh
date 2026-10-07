#!/usr/bin/env bash
# CyanLink remote relay uninstall: stops and removes the frps service that
# install-relay.sh deployed (systemd unit + config + binary).
# All output is English on purpose: it lands in CyanLink's raw log view.
set -euo pipefail

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
  command -v sudo >/dev/null 2>&1 || { echo "Error: root or sudo privilege required" >&2; exit 1; }
  SUDO="sudo"
  echo "==> Non-root user detected, privileged operations will use sudo"
fi

echo "==> Stopping and disabling cyanlink-relay service"
$SUDO systemctl disable --now cyanlink-relay 2>/dev/null || true
$SUDO rm -f /etc/systemd/system/cyanlink-relay.service
$SUDO systemctl daemon-reload

echo "==> Removing /etc/cyanlink and /usr/local/bin/frps"
$SUDO rm -rf /etc/cyanlink
$SUDO rm -f /usr/local/bin/frps

echo "==> Uninstall complete: frps service removed from this server."
