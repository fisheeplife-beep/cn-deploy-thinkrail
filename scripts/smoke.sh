#!/usr/bin/env bash
# Smoke: version + host serves ThinkRail HTML on a free port (no browser open).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="${THINKRAIL_BIN:-$(command -v thinkrail || true)}"
if [[ -z "$BIN" && -x "$HOME/.local/bin/thinkrail" ]]; then
  BIN="$HOME/.local/bin/thinkrail"
fi
if [[ -z "$BIN" || ! -x "$BIN" ]]; then
  echo "thinkrail not found — run ./scripts/install.sh first" >&2
  exit 1
fi

echo "== version =="
"$BIN" --version

PORT="${THINKRAIL_SMOKE_PORT:-24255}"
HOST="${THINKRAIL_SMOKE_HOST:-127.0.0.1}"

# Disposable git project
PROJ=$(mktemp -d)
trap 'rm -rf "$PROJ"; [[ -n "${PID:-}" ]] && kill "$PID" 2>/dev/null || true' EXIT
git -C "$PROJ" init -q
git -C "$PROJ" config user.email "smoke@cn-deploy.local"
git -C "$PROJ" config user.name "smoke"
echo "# smoke" > "$PROJ/README.md"
git -C "$PROJ" add README.md
git -C "$PROJ" commit -qm "smoke"

LOG=$(mktemp)
echo "== host --no-open --host $HOST --port $PORT =="
THINKRAIL_NO_ANALYTICS=1 "$BIN" --no-open --no-analytics --host "$HOST" --port "$PORT" "$PROJ" >"$LOG" 2>&1 &
PID=$!

# Wait for listen line / port
ok=0
for _ in $(seq 1 40); do
  if curl -fsS -m 1 -o /dev/null "http://${HOST}:${PORT}/" 2>/dev/null; then
    ok=1
    break
  fi
  sleep 0.25
done

if [[ "$ok" -ne 1 ]]; then
  echo "Host did not become ready. Log:" >&2
  cat "$LOG" >&2
  exit 1
fi

body=$(mktemp)
code=$(curl -fsS -m 5 -o "$body" -w '%{http_code}' "http://${HOST}:${PORT}/")
title=$(grep -o '<title>[^<]*</title>' "$body" | head -1 || true)
echo "HTTP $code  $title"
if [[ "$code" != "200" ]] || ! grep -qi 'ThinkRail' "$body"; then
  echo "Unexpected UI response" >&2
  head -c 400 "$body" >&2
  exit 1
fi

echo "OK — CLI ${BIN} host served ThinkRail UI"
kill "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true
PID=
cat "$LOG"
