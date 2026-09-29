# WPSApp — Store docs & release status

## 1) Privacy Policy & Support (HTML for Google Sites)

| Page | File | App Store Connect field |
|---|---|---|
| Privacy Policy | [`privacy-policy.html`](privacy-policy.html) | **Privacy Policy URL** |
| Support + Support Policy | [`support.html`](support.html) | **Support URL** |
| Hosting steps | [`GOOGLE_SITES_HOSTING.md`](GOOGLE_SITES_HOSTING.md) | — |

Contact on both pages: **impro19dev@gmail.com**  
Colors match the app (navy `#1A325F`, teal `#1ABC9C`, orange `#E67E22`).

### Publish on Google Sites
1. Create/publish a Google Site.
2. Add pages **Privacy Policy** and **Support**.
3. Insert → Embed → paste HTML from each file.
4. Publish and copy the two public HTTPS URLs into App Store Connect.

---

## 2) App Privacy Nutrition Labels

See [`APP_PRIVACY_NUTRITION_LABELS.md`](APP_PRIVACY_NUTRITION_LABELS.md) for exact answers based on current SDKs:

`network_info_plus`, `connectivity_plus`, `permission_handler`, `shared_preferences`, `url_launcher`, `http` (+ Flutter).

**Declare at minimum:** Precise Location (App Functionality, not linked, not tracking).  
**Tracking:** No.

---

## 3) Archive / IPA — **rebuild required (ITMS-90725)**

The existing IPA was built with **Xcode 16.2 / iOS 18.2 SDK**. Since April 28, 2026, App Store Connect rejects uploads unless built with **Xcode 26+ / iOS 26 SDK**.

| Field | Current IPA | Required |
|---|---|---|
| `DTXcode` | `1620` | `2600`+ |
| `DTSDKName` | `iphoneos18.2` | `iphoneos26*` |

**Fix on this Intel MacBook Pro (now on macOS Sequoia 15.8):**

App Store’s current Xcode is **27.0** and requires **macOS 26.6+**. On Sequoia you must use **Xcode 26.0–26.3** from developer.apple.com.

**Path A — stay on Sequoia 15.8 (Xcode 26.3)**
1. Unlock Apple ID at https://iforgot.apple.com if downloads say “account locked”.
2. `export PATH="$HOME/bin:$PATH"`
3. `XCODES_USERNAME=... XCODES_PASSWORD=... xcodes install "26.3" --experimental-unxip --select --no-aria2`
4. `./docs/rebuild-xcode26.sh` (verifies `DTSDKName` is `iphoneos26*`)

**Path B — upgrade to macOS Tahoe 26.7, then App Store Xcode 27**
1. System Settings → Software Update → **macOS Tahoe 26.7** (restart).
2. Mac App Store → update/install **Xcode** (27.x).
3. `sudo xcode-select -s /Applications/Xcode.app` then `./docs/rebuild-xcode26.sh` (script name is historical; it accepts any Xcode 26+ / iOS 26+ SDK).

After a successful rebuild:

- Archive: `build/ios/archive/Runner.xcarchive`
- IPA: `build/ios/ipa/WPSApp.ipa`
- Bundle ID: `com.lanlystool.wpsapp`
- Version: **1.0.0 (1)**
- Team: `49B45VHG69` (ZOUHAIR MOUFARAJ)
- Signing: Cloud Managed **Apple Distribution** (automatic)
- Export compliance: `ITSAppUsesNonExemptEncryption = false` in Info.plist

### Upload to App Store Connect (needs your API credentials)

Upload could **not** be finished automatically: no App Store Connect **Issuer ID** is configured in this environment (API `.p8` files exist in Downloads, but Issuer ID is required).

**Option A — script**

```bash
export ASC_KEY_ID=YOUR_KEY_ID          # e.g. NM89364X9G
export ASC_ISSUER_ID=YOUR-UUID-ISSUER  # from App Store Connect → Integrations
export ASC_KEY_PATH="$HOME/Downloads/AuthKey_${ASC_KEY_ID}.p8"
chmod +x docs/upload-to-asc.sh
./docs/upload-to-asc.sh
```

**Option B — Transporter app**

1. Install [Transporter](https://apps.apple.com/us/app/transporter/id1450874784) from the Mac App Store.
2. Drag `build/ios/ipa/WPSApp.ipa` into Transporter and deliver.

**Option C — Xcode**

Open `build/ios/archive/Runner.xcarchive` → Distribute App → App Store Connect → Upload.

Create the app record first in App Store Connect with bundle ID `com.lanlystool.wpsapp` if it does not exist yet.

---

## After upload

1. Paste Privacy + Support URLs in App Information.  
2. Complete App Privacy using the nutrition-labels doc.  
3. Add screenshots, description (honest: Wi‑Fi analyzer & LAN diagnostics — not password recovery).  
4. Submit for review with notes: use only on networks you own; Wi‑Fi Protected Setup tips are educational setup guidance only.
