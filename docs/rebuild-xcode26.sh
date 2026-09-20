#!/usr/bin/env bash
# Rebuild Lanlyst Tool IPA with Xcode 26+ / iOS 26+ SDK (App Store ITMS-90725).
# Prerequisites:
#   Path A: macOS Sequoia 15.6+ and Xcode 26.0–26.3 (xcodes; Apple ID must not be locked)
#   Path B: macOS Tahoe 26.6+ and App Store Xcode 27+
#   Flutter + Apple Distribution signing
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export PATH="${HOME}/bin:/usr/local/bin:${PATH}"

echo "==> Host"
sw_vers
uname -m

CUR_OS="$(sw_vers -productVersion)"
MAJOR="${CUR_OS%%.*}"

echo "==> Ensure Xcode 26+ (iOS 26+ SDK)"
XCODE_OK=0
if xcodebuild -version 2>/dev/null | awk '/Xcode/{print $2}' | python3 -c "import sys; v=sys.stdin.read().strip().split('.'); sys.exit(0 if v and int(v[0])>=26 else 1)"; then
  XCODE_OK=1
fi

if [[ "$XCODE_OK" -ne 1 ]]; then
  if [[ "$MAJOR" -ge 26 ]]; then
    echo "Install/update Xcode from the Mac App Store (27.x on Tahoe), then re-run."
    open "macappstore://apps.apple.com/app/xcode/id497799835" 2>/dev/null || true
    exit 1
  fi
  if [[ "$(python3 -c "v=tuple(int(x) for x in '$CUR_OS'.split('.')); print(1 if v>=(15,6) else 0)")" != "1" ]]; then
    echo "ERROR: macOS $CUR_OS is too old. Need Sequoia 15.6+ (Xcode 26.3) or Tahoe 26.6+ (Xcode 27)."
    exit 1
  fi
  if ! command -v xcodes >/dev/null 2>&1; then
    echo "ERROR: xcodes not in PATH (expected ~/bin/xcodes)."
    exit 1
  fi
  echo "Installing Xcode 26.3 via xcodes (Apple ID required; account must not be locked)..."
  xcodes install "26.3" --experimental-unxip --select --no-aria2
fi

sudo xcode-select -s /Applications/Xcode.app 2>/dev/null || true
sudo xcodebuild -license accept 2>/dev/null || true
xcodebuild -downloadPlatform iOS 2>/dev/null || true

echo "==> Active toolchain"
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-version

echo "==> Flutter clean + IPA"
flutter clean
flutter pub get
(cd ios && pod install)
flutter build ipa --release

IPA="build/ios/ipa/Lanlyst Tool.ipa"
test -f "$IPA"

echo "==> Verify SDK metadata (need iOS 26+ SDK)"
TMP="$(mktemp -d)"
unzip -q -o "$IPA" -d "$TMP"
APPDIR="$(find "$TMP/Payload" -maxdepth 1 -name '*.app' | head -1)"
PLIST="$APPDIR/Info.plist"
echo -n "DTXcode="; /usr/libexec/PlistBuddy -c 'Print :DTXcode' "$PLIST"
echo -n "DTSDKName="; /usr/libexec/PlistBuddy -c 'Print :DTSDKName' "$PLIST"
echo -n "DTPlatformVersion="; /usr/libexec/PlistBuddy -c 'Print :DTPlatformVersion' "$PLIST"

SDK="$(/usr/libexec/PlistBuddy -c 'Print :DTSDKName' "$PLIST")"
case "$SDK" in
  iphoneos2[6-9]*|iphoneos[3-9]*) echo "OK: $SDK — App Store SDK floor met." ;;
  *) echo "FAIL: DTSDKName=$SDK (need iphoneos26+). Do not upload."; rm -rf "$TMP"; exit 1 ;;
esac

echo "IPA ready: $ROOT/$IPA"
rm -rf "$TMP"
