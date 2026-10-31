#!/usr/bin/env bash
# Install ThinkRail CLI via the official JetBrains installer, with pinned defaults
# suitable for reproducible CN follow-along docs.
#
# Env overrides:
#   THINKRAIL_CHANNEL   stable|nightly   (default: stable)
#   THINKRAIL_VERSION   X.Y.Z|latest     (default: 0.3.0 — pin what we verified)
#   THINKRAIL_PREFIX    install prefix   (default: ~/.local → bin/thinkrail)
#   THINKRAIL_NO_MODIFY_PATH  1          skip shell rc PATH edits
#   THINKRAIL_INSTALL_URL     override install.sh URL (advanced / mirror)
set -euo pipefail

CHANNEL="${THINKRAIL_CHANNEL:-stable}"
VERSION="${THINKRAIL_VERSION:-0.3.0}"
PREFIX="${THINKRAIL_PREFIX:-$HOME/.local}"
INSTALL_URL="${THINKRAIL_INSTALL_URL:-https://raw.githubusercontent.com/JetBrains/thinkrail/main/install.sh}"

args=(--channel "$CHANNEL" --version "$VERSION" --prefix "$PREFIX")
if [[ "${THINKRAIL_NO_MODIFY_PATH:-0}" = "1" ]]; then
  args+=(--no-modify-path)
fi

echo "→ channel=$CHANNEL version=$VERSION prefix=$PREFIX"
echo "→ fetching official installer: $INSTALL_URL"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
curl -fsSL "$INSTALL_URL" -o "$tmp"
bash "$tmp" -s -- "${args[@]}"

echo
echo "Ensure PATH includes: $PREFIX/bin"
echo "  export PATH=\"$PREFIX/bin:\$PATH\""
echo "Then: thinkrail --version"
