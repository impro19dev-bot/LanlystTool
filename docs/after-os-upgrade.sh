#!/usr/bin/env bash
# Run AFTER macOS is Sequoia 15.6+ (e.g. 15.8). Installs Xcode 26.3 + rebuilds IPA.
set -euo pipefail
export PATH="${HOME}/bin:/usr/local/bin:${PATH}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "macOS $(sw_vers -productVersion) — need >= 15.6"
CUR="$(sw_vers -productVersion)"
python3 -c "import sys; v=tuple(int(x) for x in '$CUR'.split('.')); sys.exit(0 if v>=(15,6) else 1)" \
  || { echo "Upgrade macOS first."; exit 1; }

command -v xcodes >/dev/null || { echo "Missing ~/bin/xcodes"; exit 1; }

if ! xcodes installed 2>/dev/null | grep -qE '^26\.'; then
  echo "Sign in to Apple ID for developer downloads if prompted."
  xcodes install "26.3" --experimental-unxip --select
else
  P="$(xcodes installed | awk '/^26\.3 /{print $NF; exit}')"
  P="${P:-$(xcodes installed | awk '/^26\./{print $NF; exit}')}"
  sudo xcode-select -s "$P"
fi

sudo xcodebuild -license accept 2>/dev/null || true
cd "$ROOT"
exec "$ROOT/docs/rebuild-xcode26.sh"
