#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/preflight.sh"
"$ROOT/scripts/smoke.sh"
