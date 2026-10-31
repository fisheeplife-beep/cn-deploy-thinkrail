# ThinkRail 国内可跟做部署配套

> 上游仓库：[JetBrains/thinkrail](https://github.com/JetBrains/thinkrail)  
> 官网 / 文档：https://thinkrail.ai · Blog：https://thinkrail.ai/blog  
> Discord：https://thinkrail.ai/discord  
> 本仓性质：**独立中文部署配套**（脚本 / 国内网络兜底 / 踩坑记录），**不是**官方镜像，也**不会**整页搬运上游 README。

ThinkRail 是 JetBrains InnovationHub / incubator 下的 **Agentic IDE**：在 `pi` coding agent 外面套了真实 IDE 体验（Monaco、终端、diff、git worktree 工作区、SPEC 图谱等）。交付形态是：

1. **自包含 CLI** `thinkrail`（起本地 engine host，默认打开浏览器进 UI）  
2. **原生桌面安装包**（macOS DMG / Windows ZIP / Linux tarball）

本仓目标：在**国内网络 / 常见 Linux 或 macOS（及 Windows）** 上，把 **CLI 装到能冒烟**（`--version` + host 返回 ThinkRail HTML），并写清桌面包与源码开发的边界。

上游项目许可证为 **Apache-2.0**。本配套仓脚本与文档为 **MIT**，不重新授权上游代码。

社区里已有其它中文介绍/教程仓；本仓聚焦 **可复现脚本 + 验证边界 + 国内 Releases 下载**，与 [cn-deploy](https://github.com/fisheeplife-beep/cn-deploy) 系列一致。

---

## 验证边界（请先看）

| 路径 | 本仓作者环境验证状态（2026-10-31，Asia/Shanghai，Linux x86_64） |
|------|--------------------------------------------------------------|
| **官方 `install.sh` → stable `0.3.0`**（`--prefix` 临时目录，含 SHA256） | ✅ **已验证** — 见 [`examples/install-stable-0.3.0.txt`](./examples/install-stable-0.3.0.txt) |
| **`thinkrail --version`** | ✅ **已验证** — `0.3.0` |
| **`thinkrail --help`** | ✅ **已验证** — 见 [`examples/cli-version-help.txt`](./examples/cli-version-help.txt) |
| **Host：`thinkrail --no-open --host 127.0.0.1 --port … <git-repo>`** | ✅ **已验证** — 日志 `listening`，`http://127.0.0.1:…/` → **HTTP 200**，`<title>ThinkRail</title>` |
| **默认只写 `--port`（不指定 `--host`）** | ✅ **已验证** — 监听在 `[::1]`；请用 `http://localhost:…` 或显式 `--host 127.0.0.1` |
| **写入 `~/.thinkrail` 状态目录** | ✅ **已验证**（冒烟时用隔离 `HOME`） |
| **浏览器自动打开 UI / 完整首次引导（连模型供应商）** | ⚠️ **未完整走通** — 需交互登录 JetBrains AI 或配置 `pi` / Custom servers |
| **桌面安装包**（`thinkrail-desktop-linux-*.tar.gz` 等） | ⚠️ **未在本机解包实测**（依赖 GTK3 / WebKitGTK 4.1 等；按上游文档写出） |
| **nightly 通道**（如 `0.4.0-nightly.1`） | ⚠️ **脚本支持**；本仓冒烟钉的是 **stable 0.3.0** |
| **从源码 `bun install && bun run dev`** | ⚠️ **未验证**（需 Bun **1.4.4**、Node **≥ 22.19**、已认证的 `pi` 供应商；作者机 Bun/Node 版本与 pinned 不完全一致） |
| **Windows 原生** | ⚠️ **未在本机验证** — 官方提供 `install.ps1` 与 `thinkrail-windows-x64.exe` |

示例输出目录：[`examples/`](./examples/)。

**成功标准（本仓）：** `thinkrail --version` 有输出 → `./scripts/smoke.sh` 通过（临时 git 仓 + host HTML 含 ThinkRail）。

---

## 它到底怎么装？（真实安装面）

| 方式 | 命令 / 入口 | 说明 |
|------|-------------|------|
| **官方一键 CLI（推荐）** | `curl -fsSL https://raw.githubusercontent.com/JetBrains/thinkrail/main/install.sh \| bash` | 拉 GitHub Release 二进制并校验 SHA256；默认 `~/.local/bin/thinkrail` |
| **本仓脚本** | `./scripts/install.sh` | 封装官方 installer；**默认钉 stable `0.3.0`**（可用环境变量改） |
| **Release 直链** | [Releases](https://github.com/JetBrains/thinkrail/releases) | `thinkrail-{linux\|darwin}-{x64\|arm64}`、`thinkrail-windows-x64.exe`、桌面包、`SHA256SUMS` |
| **通道 / 钉版本** | `bash -s -- --channel nightly` 或 `--version 0.3.0` | Windows 用环境变量 `THINKRAIL_CHANNEL` / `THINKRAIL_VERSION` |
| **桌面** | 下 `thinkrail-desktop-*` | macOS 14+ DMG；Windows 解压 setup；Linux 解压跑 `installer`（glibc 2.38+） |
| **源码开发** | `bun install` + `bun run dev` | 给贡献者；**不是**普通用户安装路径 |

Windows CLI：

```powershell
powershell -c "irm https://raw.githubusercontent.com/JetBrains/thinkrail/main/install.ps1 | iex"
```

---

## 环境要求（最小可跑 CLI）

- **git** 在 PATH 上  
- **curl** + **sha256sum**（或 macOS `shasum`）—— 官方 installer 需要  
- **磁盘**：建议 ≥ 1–2 GB 空闲（CLI 单文件约 **235MB**）  
- **系统**：Linux x64/arm64、macOS Intel/Apple Silicon、Windows x64  
- **浏览器**（CLI 默认会 open）：本机 Chrome 等；无浏览器时用 `--no-open`  
- **模型供应商**（真正聊天时才需要）：JetBrains AI / 已有 `~/.pi/agent` / Settings → Custom servers  

可选先体检：

```bash
./scripts/preflight.sh
# 或你已有的 cn-deploy-doctor
```

Linux **桌面**额外依赖（上游说明，Ubuntu 24.04+）：

```bash
sudo apt install libgtk-3-0 libwebkit2gtk-4.1-0 libayatana-appindicator3-1 librsvg2-2
```

---

## 五分钟落地（已验证路径：CLI stable 0.3.0）

### 1. 预检

```bash
git clone https://github.com/fisheeplife-beep/cn-deploy-thinkrail.git
cd cn-deploy-thinkrail
./scripts/preflight.sh
```

### 2. 安装 CLI（钉我们实测版本）

```bash
# 国内若 GitHub 慢，先：
# export HTTPS_PROXY=http://127.0.0.1:7890
./scripts/install.sh
export PATH="$HOME/.local/bin:$PATH"
thinkrail --version    # 期望 0.3.0
```

等价官方命令：

```bash
curl -fsSL https://raw.githubusercontent.com/JetBrains/thinkrail/main/install.sh \
  | bash -s -- --channel stable --version 0.3.0
```

### 3. 冒烟（不弹浏览器）

```bash
./scripts/smoke.sh
```

手工等价：

```bash
mkdir -p /tmp/tr-demo && cd /tmp/tr-demo
git init && echo '# demo' > README.md
git add README.md && git -c user.email=a@b -c user.name=t commit -m init
thinkrail --no-open --no-analytics --host 127.0.0.1 --port 24242 .
# 另开终端：
curl -sS -D- http://127.0.0.1:24242/ | head
# 应看到 HTTP 200 与 <title>ThinkRail</title>
```

### 4. 日常使用

```bash
thinkrail                          # 起 host 并尝试打开浏览器
thinkrail ~/code/my-repo           # 打开已有 git 仓
thinkrail --no-open --host 127.0.0.1   # 远程/无 GUI：自己打开打印的 URL
thinkrail update                   # 按已装通道更新
thinkrail uninstall                # 卸载（默认保留 ~/.thinkrail）
```

状态目录默认：`~/.thinkrail`（日志、项目列表、主题/语言覆盖等）。

---

## 国内网络

见专文：[docs/china-network.md](./docs/china-network.md)。  
一句话：**安装器与二进制都走 GitHub**；~235MB 下不动就开代理或手动下 Release 再校验。

---

## 排错

见 [docs/troubleshooting.md](./docs/troubleshooting.md)。高频：

- PATH 没加 `~/.local/bin`  
- `curl 127.0.0.1` 失败但进程在听 —— 改 `localhost` 或 `--host 127.0.0.1`  
- 能开 UI 但不能聊 —— 还没配模型供应商（与安装成功是两件事）

---

## 桌面安装包（未在本机完整实测）

从 [Releases](https://github.com/JetBrains/thinkrail/releases/tag/v0.3.0) 选：

- macOS：`thinkrail-desktop-darwin-arm64.dmg` / `…-x64.dmg`  
- Windows：`thinkrail-desktop-windows-x64.zip`（解压后就地跑 setup）  
- Linux：`thinkrail-desktop-linux-x64.tar.gz` / `…-arm64…`（解压后跑 `installer`）

稳定版与 nightly 桌面包会在 **Settings → Updates** 提示更新（需有效 HTTPS feed identity）。细节以官方 README「Desktop」一节为准。

---

## 源码开发（贡献者路径，未在本仓冒烟）

上游要求 **Bun 1.4.4**、**Node ≥ 22.19**、可用的 `pi` 供应商：

```bash
git clone https://github.com/JetBrains/thinkrail.git
cd thinkrail
bun install
bun run dev
```

国内还要解决 npm/Bun 注册表与依赖拉取问题；普通「只想用 IDE」请走 **Release CLI/桌面**，不要从源码装。

---

## 与上游的关系

- 功能、协议、UI 行为以 [JetBrains/thinkrail](https://github.com/JetBrains/thinkrail) 为准。  
- 本仓只提供中文跟做步骤、预检/安装封装、冒烟脚本与国内网络说明。  
- 发现产品 bug 请去上游 Issues；本仓 Issue 只收「配套文档/脚本」问题。

---

## License

本仓：[MIT](./LICENSE)  
上游 ThinkRail：Apache-2.0  
`pi` 及相关 npm 包：见各自许可证  
