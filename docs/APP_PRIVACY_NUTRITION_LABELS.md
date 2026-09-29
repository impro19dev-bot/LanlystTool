# WPSApp — App Privacy (Nutrition Labels)

Use this when filling **App Store Connect → App Privacy**.

**Developer contact:** impro19dev@gmail.com  
**Bundle ID:** `com.lanlystool.wpsapp`  
**Based on SDKs / packages in `pubspec.yaml` as of Sep 12, 2026**

---

## SDKs currently in use

| Package | Purpose | Data implications |
|---|---|---|
| `network_info_plus` | Wi‑Fi name / IP / gateway / BSSID | Device network info (on device; Location needed for SSID) |
| `connectivity_plus` | Wi‑Fi vs cellular connectivity | Device network status |
| `permission_handler` | Request Location (When In Use) | Permission prompts only |
| `shared_preferences` | Checklist / local settings | Device ID-adjacent local storage (UserDefaults) — **not** sent to developer servers |
| `url_launcher` | Open router admin / links | Opens system browser; no analytics SDK |
| `http` | Speed test, HTTP headers, MAC vendor, RDAP/Whois | User-initiated network requests to third parties |
| `google_mobile_ads` (via `multiads`) | Banner ads (AdMob) | Advertising data / Device ID (IDFA/AAID) via Google |

**Advertising SDK:** Google Mobile Ads is included for banners.

---

## Recommended App Privacy answers

### Do you or your third-party partners collect data from this app?

**Yes** — network diagnostics (as below) **and** advertising data via Google AdMob.

### Privacy Policy URL

After hosting `docs/privacy-policy.html` on Google Sites, paste that public URL here.

---

## Data types to declare

### 1. Location — **Precise Location** (optional but recommended)

| Field | Value |
|---|---|
| Collected? | **Yes** (iOS requires Location permission to read Wi‑Fi SSID) |
| Linked to identity? | **No** |
| Used for tracking? | **No** |
| Purposes | **App Functionality** |
| Notes | Used only to display current network name / related Wi‑Fi details. Not used for ads or movement tracking. |

You may also leave **Coarse Location** unchecked if you only use When-In-Use for SSID.

### 2. Identifiers — **Device ID**

| Field | Value |
|---|---|
| Collected? | **Yes** (via Google Mobile Ads / advertising identifier) |
| Linked to identity? | **No** |
| Used for tracking? | **Yes** if personalized ads use IDFA across apps — declare per your ATT/consent setup; use **No** only if you serve non-personalized ads only |
| Purposes | **Third-Party Advertising**, **Developer’s Advertising or Marketing** (as applicable) |

### 2b. Advertising Data

| Field | Value |
|---|---|
| Collected? | **Yes** (AdMob banners) |
| Linked? | **No** |
| Tracking? | Follow Google AdMob / ATT guidance |
| Purposes | **Third-Party Advertising** |

`shared_preferences` stores checklist state locally only → do **not** attribute Device ID to that alone.

### 3. Diagnostics — **Other Diagnostic Data** / **Performance Data**

| Field | Value |
|---|---|
| Collected by you? | **No** (no Crashlytics / analytics SDK) |

### 4. Contact Info — **Email Address**

| Field | Value |
|---|---|
| Collected in-app? | **No** |
| Via support email? | Only if the user emails you voluntarily (outside the App). Usually **not** declared as “collected from the app” unless the app has a form that sends email content to you automatically. |

### 5. Usage Data / Product Interaction

| Field | Value |
|---|---|
| Collected? | **No** (no analytics SDK) |

### 6. Other Data — **Other User Content** / network queries (optional nuance)

When the user runs:

- DNS / Whois / HTTP headers / MAC vendor / speed test  

the **query** (hostname, URL, MAC) and the device’s **IP address** are sent to third-party endpoints.

Recommended conservative declaration:

| Data type | Collected? | Linked? | Tracking? | Purposes |
|---|---|---|---|---|
| **Other User Content** (queries the user types) | Yes (user-initiated) | No | No | App Functionality |
| **IP Address** (under **Network Info** / **Device ID**-adjacent; Apple lists **IP Address** under Diagnostics or Other — use **Other Data Types → IP Address** if shown, or **Diagnostics**) | Yes (as part of HTTPS requests the OS makes) | No | No | App Functionality |

If the App Store Connect UI only offers coarse buckets, prioritize:

1. **Precise Location** — App Functionality — not linked — not used for tracking  
2. **Product Interaction** — **No**  
3. **Advertising Data** — **No**  
4. **Purchases** — **No**  
5. **Search History** — **No** unless you store searches (currently not persisted to your servers)

---

## Tracking

**Does this app use data for tracking?** → **Yes** if AdMob uses the advertising identifier for cross-app advertising (typical default). Request App Tracking Transparency when required, or configure non-personalized ads and answer accordingly.

No separate ATT analytics SDK beyond ads.

---

## Data linked to the user

**No** data types should be marked as “linked to the user’s identity” (no accounts).

---

## Data used to track the user

Leave **all unchecked**.

---

## Third-party partners

**Google AdMob** (via `google_mobile_ads` / `multiads`) serves banner ads and may collect advertising identifiers and related data.

User-initiated tools may also call public APIs (e.g. Cloudflare speed sample, MAC vendor, RDAP). Those partners receive request metadata as any HTTPS client would.

---

## Export compliance (Archive)

In `Info.plist`, set:

`ITSAppUsesNonExemptEncryption` = `false`

(unless you later add custom non-exempt cryptography beyond HTTPS).

Answer App Store Connect export compliance accordingly: **uses standard encryption only (HTTPS)**.

---

## Checklist before submit

- [ ] Host Privacy Policy HTML → paste URL in App Privacy + App Information  
- [ ] Host Support HTML → paste URL as Support URL  
- [ ] Fill Nutrition Labels using this document  
- [ ] Review Notes: “Use only on networks you own; Wi‑Fi Protected Setup tips are educational; iOS cannot read AP WPS status. App is a Wi‑Fi analyzer & scanner.”
