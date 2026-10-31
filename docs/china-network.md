# 国内网络说明（ThinkRail）

## 你需要通的几条链路

| 用途 | 地址 | 国内常见情况 |
|------|------|----------------|
| 官方安装脚本 | `https://raw.githubusercontent.com/JetBrains/thinkrail/main/install.sh` | raw.githubusercontent.com 偶发慢/超时 |
| 解析版本 | `https://api.github.com/repos/JetBrains/thinkrail/releases…` | api.github.com 常需代理 |
| CLI / Desktop 资产 | `https://github.com/JetBrains/thinkrail/releases/download/<tag>/…` | **主卡点**：`thinkrail-linux-x64` 约 **235MB** |
| 校验和文件 | 同 Releases 的 `SHA256SUMS` | 与 GitHub Releases 同命运 |
| 官网 / Discord | thinkrail.ai | 一般可访问；Discord 另说 |
| pi / 模型供应商 | 各厂商 API（OpenAI、Anthropic、JetBrains AI、自建 OpenAI-compatible 等） | 与 ThinkRail 安装无关；聊天时才需要 |

ThinkRail **不是** Docker 服务：没有「拉镜像」这一步。卡点几乎总在 **第一次从 GitHub Releases 拉 ~235MB CLI 二进制**（桌面安装包更大）。

## 推荐策略（按优先级）

1. **能直连 GitHub Releases**（本仓作者环境可直连）：
   ```bash
   ./scripts/preflight.sh
   ./scripts/install.sh          # 默认钉 stable 0.3.0
   export PATH="$HOME/.local/bin:$PATH"
   ./scripts/smoke.sh
   ```
2. **GitHub 慢 / 超时**：先开本地 HTTP 代理再装：
   ```bash
   export HTTPS_PROXY=http://127.0.0.1:7890
   export HTTP_PROXY=http://127.0.0.1:7890
   # 若用 SOCKS：
   # export ALL_PROXY=socks5://127.0.0.1:7890
   ./scripts/install.sh
   ```
3. **只能浏览器/网盘手动下载**：到 [Releases](https://github.com/JetBrains/thinkrail/releases) 下载对应平台的 `thinkrail-*` 与 `SHA256SUMS`，校验后放到 `<prefix>/bin/thinkrail` 并 `chmod +x`。自更新要求文件名正好是 `thinkrail`（Windows 为 `thinkrail.exe`），见上游 README。
4. **不要用不明第三方「加速脚本」改写官方 installer 逻辑**；可镜像的是 **下载源**，校验仍应对官方 `SHA256SUMS`。

## 安装脚本与 raw.githubusercontent.com

若 `curl …/install.sh` 本身就失败，可：

```bash
# 已能访问 GitHub 网页时：浏览器打开 install.sh raw 页另存，再：
bash ./install.sh -s -- --channel stable --version 0.3.0 --prefix "$HOME/.local"
# 或用本仓脚本并改 URL（高级）：
# THINKRAIL_INSTALL_URL=file:///path/to/install.sh ./scripts/install.sh
```

本仓 `./scripts/install.sh` 只是对官方脚本的薄封装（默认钉我们实测过的版本），**不替代**上游安装器。

## 跑起来之后还要通什么

- **模型供应商**：首次使用需 JetBrains AI 登录或 `pi` 已有凭证 / Settings 里配 Custom servers。国内常用：可访问的 OpenAI-compatible 网关、本地 Ollama / LM Studio 等（见上游 README「Your own model servers」）。
- **GitHub PR / CI 面板**：需要本机 `gh` 已登录且网络能访问 GitHub；与「能不能打开 ThinkRail UI」无关。

## 不要做的事

- 不要跳过 SHA256 校验直接跑不明二进制。
- 不要把 `--host 0.0.0.0` 暴露到公网（默认只绑 localhost）。
- 不要把本仓当成上游 fork；升级请跟 [JetBrains/thinkrail releases](https://github.com/JetBrains/thinkrail/releases)。
