#!/usr/bin/env bash
# CyanLink 远程中继一键安装脚本（公共静态脚本；纯安装，无任何回调）
#
# 用法（参数由 CyanLink「安装 / 重试」抽屉生成，一键复制）:
#   curl -fsSL <本脚本URL> | bash -s -- \
#     --bind-port <frps端口> --frps-token <frp认证token> \
#     [--frp-dl-base <frp镜像源>] [--frp-version <版本>]
#
# 说明: 脚本只负责把 frps 装好并拉起；安装是否成功由 CyanLink 主动探测
#       frps 控制端口（bind_port）确认。请确保安全组/防火墙放行 bind_port。
set -euo pipefail

BIND_PORT="" FRPS_TOKEN=""
FRP_VERSION="${FRP_VERSION:-0.61.2}"
FRP_DL_BASE="${FRP_DL_BASE:-https://github.com/fatedier/frp/releases/download}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bind-port) BIND_PORT="$2"; shift 2 ;;
    --frps-token) FRPS_TOKEN="$2"; shift 2 ;;
    --frp-dl-base) FRP_DL_BASE="$2"; shift 2 ;;
    --frp-version) FRP_VERSION="$2"; shift 2 ;;
    *) echo "未知参数: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$BIND_PORT" && -n "$FRPS_TOKEN" ]] || {
  echo "缺少 --bind-port / --frps-token" >&2; exit 1;
}

echo "==> CyanLink 远程中继安装（bindPort=${BIND_PORT}）"

ARCH=$(uname -m)
case "$ARCH" in
  x86_64) FRP_ARCH="amd64" ;;
  aarch64 | arm64) FRP_ARCH="arm64" ;;
  *) echo "不支持的架构: $ARCH" >&2; exit 1 ;;
esac

if ! command -v frps >/dev/null 2>&1; then
  echo "==> 下载 frp v${FRP_VERSION} (linux-${FRP_ARCH})"
  TGZ="$(mktemp /tmp/frp.XXXXXX.tar.gz)"
  curl -fsSL "${FRP_DL_BASE}/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${FRP_ARCH}.tar.gz" -o "$TGZ" \
    || curl -fsSL "https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${FRP_ARCH}.tar.gz" -o "$TGZ"
  # 二进制必须先落盘再 install：命令替换会把 >128KB 的参数撑爆 ARG_MAX（Argument list too long），
  # 且 bash 会剥离 NUL 字节导致二进制损坏。
  EXTRACT_DIR="$(mktemp -d)"
  tar -xzf "$TGZ" -C "$EXTRACT_DIR" "frp_${FRP_VERSION}_linux_${FRP_ARCH}/frps"
  install -m 0755 "$EXTRACT_DIR/frp_${FRP_VERSION}_linux_${FRP_ARCH}/frps" /usr/local/bin/frps
  rm -rf "$EXTRACT_DIR" "$TGZ"
fi

echo "==> 写入 /etc/cyanlink/frps.toml"
mkdir -p /etc/cyanlink
cat > /etc/cyanlink/frps.toml <<CFG
bindAddr = "0.0.0.0"
bindPort = ${BIND_PORT}
auth.token = "${FRPS_TOKEN}"
CFG

echo "==> 注册 systemd 服务 cyanlink-relay"
cat > /etc/systemd/system/cyanlink-relay.service <<UNIT
[Unit]
Description=CyanLink relay (frps)
After=network-online.target

[Service]
ExecStart=/usr/local/bin/frps -c /etc/cyanlink/frps.toml
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable cyanlink-relay >/dev/null
# 幂等重装：enable --now 不会重启已运行的 unit，改配后必须显式 restart 才能生效
systemctl restart cyanlink-relay

echo "==> 完成：frps 已运行。请在云安全组/防火墙放行 TCP ${BIND_PORT}，"
echo "    CyanLink 探测通过后实例将自动显示在线。"
