#!/usr/bin/env bash
# Preflight for installing / using ThinkRail (JetBrains/thinkrail) on a CN-friendly host.
set -euo pipefail

ok=0; warn=0; bad=0
say() { printf '%s\n' "$*"; }
pass() { say "✅ $*"; ok=$((ok+1)); }
warn_() { say "⚠️  $*"; warn=$((warn+1)); }
fail() { say "❌ $*"; bad=$((bad+1)); }

say "=== ThinkRail CN preflight ==="
say ""

# OS / arch
os=$(uname -s)
arch=$(uname -m)
case "$os" in
  Linux*) os_key=linux ;;
  Darwin*) os_key=darwin ;;
  *) os_key=other ;;
esac
case "$arch" in
  x86_64|amd64) arch_key=x64 ;;
  arm64|aarch64) arch_key=arm64 ;;
  *) arch_key=other ;;
esac
if [[ "$os_key" != other && "$arch_key" != other ]]; then
  pass "Platform $os/$arch → CLI asset thinkrail-${os_key}-${arch_key}"
else
  fail "Unsupported or unknown platform: $os/$arch (official CLI: linux/darwin x64|arm64, windows x64)"
fi

# git (required by thinkrail)
if command -v git >/dev/null 2>&1; then
  pass "git $(git --version | awk '{print $3}')"
else
  fail "git missing — ThinkRail needs git on PATH"
fi

# curl (installer)
if command -v curl >/dev/null 2>&1; then
  pass "curl available (official install.sh needs it)"
else
  fail "curl missing — needed by official install.sh"
fi

# sha256
if command -v sha256sum >/dev/null 2>&1 || command -v shasum >/dev/null 2>&1; then
  pass "sha256 tool present (installer verifies SHA256SUMS)"
else
  warn_ "No sha256sum/shasum — official installer may fail checksum step"
fi

# Disk (~235MB binary + headroom)
if df -P "$HOME" >/dev/null 2>&1; then
  avail_kb=$(df -Pk "$HOME" | awk 'NR==2{print $4}')
  avail_gb=$((avail_kb / 1024 / 1024))
  if [[ "$avail_gb" -ge 2 ]]; then
    pass "Home disk free ~${avail_gb} GB (CLI binary ~235MB)"
  else
    warn_ "Home disk free ~${avail_gb} GB — CLI download needs ~250MB+"
  fi
fi

# Proxy hints
if [[ -n "${HTTPS_PROXY:-}${https_proxy:-}${HTTP_PROXY:-}${http_proxy:-}${ALL_PROXY:-}${all_proxy:-}" ]]; then
  pass "HTTP(S)_PROXY / ALL_PROXY set (helps GitHub Releases in CN)"
else
  warn_ "No proxy env set — GitHub Releases (~235MB) often times out in CN; see docs/china-network.md"
fi

# GitHub API / releases reachability (best-effort, short timeout)
if curl -fsS -m 8 -o /dev/null -w '' "https://api.github.com/repos/JetBrains/thinkrail/releases/latest" 2>/dev/null; then
  pass "api.github.com reachable (installer resolves latest tag)"
else
  warn_ "api.github.com not reachable in 8s — installer will fail without proxy/mirror"
fi

# Existing install
if command -v thinkrail >/dev/null 2>&1; then
  pass "thinkrail already on PATH: $(thinkrail --version 2>/dev/null || echo unknown)"
elif [[ -x "${HOME}/.local/bin/thinkrail" ]]; then
  warn_ "Found ~/.local/bin/thinkrail but not on PATH — export PATH=\"\$HOME/.local/bin:\$PATH\""
else
  say "   (thinkrail not installed yet)"
fi

# Browser (CLI opens UI in browser unless --no-open)
browser_ok=0
for b in google-chrome google-chrome-stable chromium chromium-browser microsoft-edge brave-browser; do
  if command -v "$b" >/dev/null 2>&1; then
    pass "Browser candidate: $b (CLI can open UI)"
    browser_ok=1
    break
  fi
done
if [[ "$browser_ok" -eq 0 ]]; then
  if [[ "$os_key" = darwin ]]; then
    pass "macOS — system browser usually available via open(1)"
  else
    warn_ "No Chrome/Chromium on PATH — use desktop app, or thinkrail --no-open and open http://127.0.0.1:24242 yourself"
  fi
fi

# Optional: Bun/Node for source-dev path only
if command -v bun >/dev/null 2>&1; then
  say "   bun $(bun -v) present (only needed for source build / bun run dev)"
fi
if command -v node >/dev/null 2>&1; then
  say "   node $(node -v) present (source-dev needs ≥22.19; CLI binary does not need Node)"
fi

say ""
say "Summary: ${ok} pass, ${warn} warn, ${bad} fail"
if [[ "$bad" -gt 0 ]]; then
  exit 1
fi
exit 0
