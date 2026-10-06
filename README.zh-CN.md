# cyanlink-public

[English](README.md) | [简体中文](README.zh-CN.md)

**CyanLink** 公共分发仓库：远程中继一键安装脚本。
frp 二进制默认直接从 [frp 官方 GitHub Release](https://github.com/fatedier/frp/releases) 下载——本仓库无需托管二进制。

## 资源

| 资源 | 地址 |
|---|---|
| 安装脚本 | `https://raw.githubusercontent.com/mazefakeyoo/cyanlink-public/main/scripts/install-relay.sh` |
| frp 二进制（默认源） | `https://github.com/fatedier/frp/releases/download/v<版本>/frp_<版本>_linux_<架构>.tar.gz` |
| 备份镜像（v0.61.2，amd64/arm64） | [Releases](https://github.com/mazefakeyoo/cyanlink-public/releases) —— 官方原包，未做修改 |

## 手动安装远程中继

在目标服务器（Ubuntu/Debian，x86_64 或 arm64，需 root）执行：

```bash
curl -fsSL https://raw.githubusercontent.com/mazefakeyoo/cyanlink-public/main/scripts/install-relay.sh \
  | bash -s -- --bind-port 7000 --frps-token <你的frps-token>
```

### 参数说明

| 参数 | 必填 | 说明 |
|---|---|---|
| `--bind-port` | 是 | frps 控制端口（防火墙/安全组需放行） |
| `--frps-token` | 是 | frp 认证 token，须与 CyanLink 实例生成的 token 一致 |
| `--frp-dl-base` | 否 | 自定义下载源，路径约定 `<base>/v<版本>/<文件名>`；默认 frp 官方 GitHub Release |
| `--frp-version` | 否 | 安装的 frp 版本（默认 `0.61.2`） |

## 工作方式

- 脚本只负责把 frps 装好并拉起（systemd 单元 `cyanlink-relay`，配置 `/etc/cyanlink/frps.toml`），**不做任何回调**——是否安装成功由 CyanLink 主动探测控制端口（`bind_port`）并校验 token 裁决。
- 下载顺序：先 `<frp-dl-base>`，失败自动回退 frp 官方 GitHub Release；本机已有 frps 则跳过下载。
- **单台服务器仅支持一个中继实例**：脚本使用固定配置路径与单元名；携带不同参数重复执行即为改配重装（重写配置并 `systemctl restart`），无需手动清理。
- 仅依赖 root 权限与 `curl`，无其他依赖。

## 完整性

备份镜像 Release 内的 tar.gz 均为 [fatedier/frp](https://github.com/fatedier/frp/releases) 官方发布原包（Apache-2.0），未做任何修改。v0.61.2 SHA256：

```
4738edbd4bf88db5fe0ccee946d63da3b498c9cc50b0c7317d017fe7d28a05ea  frp_0.61.2_linux_amd64.tar.gz
6c80eb8549899e4a6f0d1c04cda58bfba47be949c308f6e55662f20b807296c2  frp_0.61.2_linux_arm64.tar.gz
```

## 版权与声明

frp (Fast Reverse Proxy) — Copyright (c) fatedier，Apache-2.0 许可。本仓库仅分发未修改的官方发行包与安装脚本；CyanLink 与 frp 项目无隶属关系。
