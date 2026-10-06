# cyanlink-public

CyanLink 公共分发仓库：远程中继一键安装脚本 + frp 发行包镜像。

## 内容

| 资源 | 直链 |
|---|---|
| 安装脚本 | `https://raw.githubusercontent.com/mazefakeyoo/cyanlink-public/main/scripts/install-relay.sh` |
| frp 二进制（v0.61.2，amd64/arm64） | `https://github.com/mazefakeyoo/cyanlink-public/releases/download/v0.61.2/frp_0.61.2_linux_amd64.tar.gz` 等，见 [Releases](https://github.com/mazefakeyoo/cyanlink-public/releases) |

## 手动安装远程中继

在目标服务器（Ubuntu/Debian，需 root）执行：

```bash
curl -fsSL https://raw.githubusercontent.com/mazefakeyoo/cyanlink-public/main/scripts/install-relay.sh \
  | bash -s -- --bind-port 7000 --frps-token <你的frps-token> \
      --frp-dl-base https://github.com/mazefakeyoo/cyanlink-public/releases/download
```

说明：

- 脚本只负责把 frps 装好并拉起（systemd 单元 `cyanlink-relay`）；安装是否成功由 CyanLink 主动探测 `bind_port` 确认，脚本不做任何回调。
- `--frp-dl-base` 省略时默认直接从 frp 官方 GitHub Release 下载（任意版本可用）；如需自建镜像，传入自定义 base 即可，下载失败自动回退官方源。
- 单台服务器只支持一个中继实例（脚本使用固定的 `/etc/cyanlink/frps.toml` 与 `cyanlink-relay` 单元；重复执行即为改配重装，会自动重启服务）。
- 重复执行幂等：重写配置并 `systemctl restart`。
- 请在防火墙/安全组放行 `bind_port`。

## frp 二进制完整性

Release 内的 tar.gz 均取自 [fatedier/frp](https://github.com/fatedier/frp/releases) 官方发布原包（Apache-2.0），未做任何修改；v0.61.2 SHA256：

```
4738edbd4bf88db5fe0ccee946d63da3b498c9cc50b0c7317d017fe7d28a05ea  frp_0.61.2_linux_amd64.tar.gz
6c80eb8549899e4a6f0d1c04cda58bfba47be949c308f6e55662f20b807296c2  frp_0.61.2_linux_arm64.tar.gz
```

frp 版权与许可：Copyright (c) fatedier, License Apache-2.0。
