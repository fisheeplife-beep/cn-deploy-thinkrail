# cn-deploy-thinkrail

> **Series index:** [cn-deploy](https://github.com/fisheeplife-beep/cn-deploy) — Chinese follow-along deployment companions.

Chinese, follow-along **deployment companion** for [JetBrains/thinkrail](https://github.com/JetBrains/thinkrail) — not an official fork, and not a verbatim copy of upstream docs.

**Start here (ZH):** [README.zh-CN.md](./README.zh-CN.md)

### What you get

- Preflight / install (pins **stable 0.3.0** by default) / smoke / verify scripts
- China network notes (`docs/china-network.md`) and troubleshooting
- Example outputs: official installer, `thinkrail --version`/`--help`, host HTTP 200 UI

### Verification snapshot (author box, 2026-10-31, Asia/Shanghai, Linux x86_64)

| Path | Status |
|------|--------|
| Official `install.sh` → **stable 0.3.0** + SHA256 | **Verified** |
| `thinkrail --version` → `0.3.0` | **Verified** |
| Host `--no-open --host 127.0.0.1` → UI HTML **HTTP 200** (`<title>ThinkRail</title>`) | **Verified** |
| Default bind without `--host` listens on `[::1]` — use `localhost` or `--host 127.0.0.1` | **Verified** |
| Full first-run provider login / chat | **Not fully walked** (needs interactive auth) |
| Desktop packages / nightly / source `bun run dev` / Windows native | **Not verified** on this host |

### Quick start

```bash
./scripts/preflight.sh
# export HTTPS_PROXY=http://127.0.0.1:7890   # if GitHub Releases is slow
./scripts/install.sh          # → ~/.local/bin, stable 0.3.0
export PATH="$HOME/.local/bin:$PATH"
./scripts/smoke.sh
thinkrail --no-open --host 127.0.0.1 ~/path/to/git-repo
```

Upstream is **Apache-2.0**. This companion (scripts + notes) is [MIT](./LICENSE).  
Site: https://thinkrail.ai/ · Releases: https://github.com/JetBrains/thinkrail/releases
