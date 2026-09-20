#!/bin/zsh
# Upload Lanlyst Tool IPA to App Store Connect.
# Requires an App Store Connect API key (.p8) + Issuer ID.
#
# Usage:
#   export ASC_KEY_ID=XXXXXXXXXX
#   export ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#   export ASC_KEY_PATH="$HOME/Downloads/AuthKey_XXXXXXXXXX.p8"
#   ./docs/upload-to-asc.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IPA="$ROOT/build/ios/ipa/Lanlyst Tool.ipa"

if [[ ! -f "$IPA" ]]; then
  echo "IPA not found. Build first:"
  echo "  cd \"$ROOT\" && flutter build ipa --release"
  exit 1
fi

if [[ -z "${ASC_KEY_ID:-}" || -z "${ASC_ISSUER_ID:-}" || -z "${ASC_KEY_PATH:-}" ]]; then
  echo "Set ASC_KEY_ID, ASC_ISSUER_ID, and ASC_KEY_PATH first."
  echo "Create a key at: App Store Connect → Users and Access → Integrations → App Store Connect API"
  exit 1
fi

KEY_DIR="$HOME/.appstoreconnect/private_keys"
mkdir -p "$KEY_DIR"
cp -f "$ASC_KEY_PATH" "$KEY_DIR/AuthKey_${ASC_KEY_ID}.p8"

echo "Uploading: $IPA"
xcrun altool --upload-app --type ios \
  -f "$IPA" \
  --apiKey "$ASC_KEY_ID" \
  --apiIssuer "$ASC_ISSUER_ID"

echo "Done. Check App Store Connect → TestFlight / Activity for processing."
