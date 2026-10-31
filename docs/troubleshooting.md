# 排错速查（ThinkRail）

| 现象 | 可能原因 | 处理 |
|------|----------|------|
| `curl … install.sh` 超时 | raw.githubusercontent.com / 代理未开 | 开 `HTTPS_PROXY`；或手动保存 install.sh 再 `bash` |
| `Failed to resolve a stable release` | api.github.com 不通 | 代理；或 `--version 0.3.0` 仍需 API/Releases；改手动下载资产 |
| 下载到一半失败 / 校验失败 | Releases 弱网、文件截断 | 重试；对照 `SHA256SUMS`；换代理节点 |
| `thinkrail: command not found` | PATH 未含 `<prefix>/bin` | `export PATH="$HOME/.local/bin:$PATH"`；新开终端 |
| 启动后浏览器打不开 | 无 GUI 浏览器 / 远程机器 | `thinkrail --no-open --host 127.0.0.1`，本机浏览器访问打印的 URL；或 SSH 端口转发 |
| `curl 127.0.0.1:24242` 失败但日志写 listening | 默认可能只听在 `[::1]` | 用 `http://localhost:24242`，或启动时加 `--host 127.0.0.1` |
| 需要 git repo | 上游要求 PATH 上有 git；也可在 UI 里「Start a new project」 | `sudo apt install git` 等；或让 UI 建空仓 |
| Linux 桌面装不上 / 打不开 | 缺 GTK3 / WebKitGTK 4.1 等；需 glibc 2.38+ | 按上游：Ubuntu 24.04+ 装 `libgtk-3-0 libwebkit2gtk-4.1-0 libayatana-appindicator3-1 librsvg2-2`；或只用 CLI |
| Alpine / musl | 官方 Linux 二进制走 glibc | 换 Debian/Ubuntu，或 WSL2 |
| Agent 不能聊 | 未配置模型供应商 | Settings 登录 JetBrains AI，或接 `pi` / Custom OpenAI-compatible |
| 想关额外分析 | 隐私开关 / 启动参数 | `thinkrail --no-analytics` 或 `THINKRAIL_NO_ANALYTICS=1` |

更完整的产品行为以 [上游 README](https://github.com/JetBrains/thinkrail/blob/main/README.md) 为准。
