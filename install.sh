#!/bin/sh
# Installs Chiron, long-term memory for your AI agents, kept on this computer.
#   curl -fsSL https://raw.githubusercontent.com/Mad-Science-Software/chiron-beta/main/install.sh | sh
# Downloads the latest release for this Mac or Linux machine, checks it
# against the release's checksums, puts it in ~/.chiron/bin and starts it at
# login. No admin password. Set CHIRON_VERSION=0.4.0 to install a specific one.
set -eu

releases="https://github.com/Mad-Science-Software/chiron-beta/releases"
if [ -n "${CHIRON_VERSION:-}" ]; then
  base="$releases/download/v$CHIRON_VERSION"
else
  base="$releases/latest/download"
fi

case "$(uname -s)/$(uname -m)" in
  Darwin/*)              asset="chiron-darwin-universal" ;;
  Linux/x86_64)          asset="chiron-linux-amd64" ;;
  Linux/aarch64|Linux/arm64) asset="chiron-linux-arm64" ;;
  *) echo "Chiron doesn't have a release for $(uname -s) $(uname -m) yet." >&2; exit 1 ;;
esac

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
echo "Downloading Chiron ($asset)…"
curl -fsSL "$base/$asset" -o "$work/$asset"
curl -fsSL "$base/checksums.txt" -o "$work/checksums.txt"

expected="$(awk -v name="$asset" '$2 == name || $2 == "*"name { print $1 }' "$work/checksums.txt")"
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$work/$asset" | awk '{print $1}')"
else
  actual="$(shasum -a 256 "$work/$asset" | awk '{print $1}')"
fi
if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
  echo "The download doesn't match the release's checksum; not installing it." >&2
  exit 1
fi

chmod 755 "$work/$asset"
"$work/$asset" install
echo
echo "Installed. Next: add the Claude Code plugin (see docs/setup.md), then start a new Claude Code session."
