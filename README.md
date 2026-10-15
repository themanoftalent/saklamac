# Saklamac Pro 🥷

> **The Modern, World-Class Menu Bar Powerhouse for macOS**  
> *"Saklamaç"* — Turkish for *Hide-and-Seek*. Hide what you don't need, master what you do.

[![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue?logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Architecture](https://img.shields.io/badge/Architecture-Apple%20Silicon%20%7C%20ARM64-purple)](https://developer.apple.com)
[![Developer](https://img.shields.io/badge/Developer-Mehmet%20Akif%20Cifci-darkgreen)](https://github.com/themanoftalent)
[![Brand](https://img.shields.io/badge/Brand-TheManOfTalent-gold)](https://github.com/themanoftalent)

**Saklamac Pro** is a commercial-grade, privacy-respecting macOS menu bar manager developed from the ground up using Swift 6 and modern SwiftUI. Designed to solve the challenges of crowded menu bars and MacBook display camera notches, Saklamac combines a multi-zone layout engine with a floating overflow shelf, Spotlight-style quick search, gesture controls, workspace profiles, and native macOS 27+ WindowServer integration.

---

## 👨‍💻 Developer & Brand Identity

- **Company / Developed by**: **SoftAI Yazılım**
- **Developer**: **Assoc. Prof. Dr. Mehmet Akif Cifci**
- **Brand / GitHub**: [@themanoftalent](https://github.com/themanoftalent)
- **Official Repository**: [https://github.com/themanoftalent/saklamac](https://github.com/themanoftalent/saklamac)
- **Sponsor**: [GitHub Sponsors](https://github.com/sponsors/themanoftalent)
- **Support**: [Buy Me a Coffee](https://buymeacoffee.com/themanoftalent)

---

## ✨ Flagship Capabilities

### 1. 🪟 The Saklamac Floating Shelf
A frosted-glass secondary dropdown bar that appears directly underneath your menu bar. Specially crafted for MacBooks with camera notches, the shelf houses overflow icons so they never get swallowed behind the physical camera notch. Toggle it anytime with `⌘⌥S`.

### 2. 🔍 Spotlight-Style Quick Search
Press `⌘⌥Space` to summon a floating search HUD in the center of your display. Instantly filter through all running menu bar applications, check their assigned visibility zone, and press Enter to focus and activate them.

### 3. 📁 Workspace Profiles & Presets
Switch entire menu bar configurations with a single click:
- **Default (Balanced)**: Standard everyday desktop configuration.
- **Zen Minimalist**: Extreme distraction-free layout (only Clock & Battery).
- **Work & Productivity**: Keeps Slack, Zoom, and developer tools in immediate reach.
- **Presentation Mode**: Automatically hides private chat badges and personal utility icons.
- **Custom Presets**: Create unlimited custom profiles, duplicate, and export/import them as JSON.

### 4. 🎛️ Live App Manager
- Scans all running applications displaying status items.
- Real-time search and filtering (*All*, *Visible*, *Drawer*, *Ghost Zone*).
- Instant segmented zone overrides (*Visible*, *Drawer*, *Ghost Zone*).
- Direct "Bring App to Foreground" launcher buttons.

### 5. 🖱️ Advanced Gestures & Triggers
- **Hover to Expand**: Cursor rests in the menu bar for a customizable dwell duration (0.1s to 1.5s) to reveal icons.
- **Scroll Wheel / Swipe**: Swipe horizontally or scroll vertically anywhere across the menu bar to toggle the drawer.
- **Empty Space Click**: Click an empty area of the menu bar to reveal or collapse icons.
- **Smart Auto-Collapse**: Automatically re-hides icons after inactivity, with cursor collision protection.

### 6. ⌨️ Global Shortcuts & Floating HUD Bezel
- 4 customizable Carbon global hotkeys:
  - Toggle Drawer (`⌘⌥H`)
  - Toggle Ghost Zone (`⌘⌥J`)
  - Quick Search HUD (`⌘⌥Space`)
  - Toggle Floating Shelf (`⌘⌥S`)
- Floating on-screen translucent bezel notification.
- Tactile sound feedback with 6 selectable system effects (*Pop*, *Tink*, *Bottle*, *Funk*, *Purr*, *Submarine*).

### 7. 🎨 Appearance & Density Control
- 8 custom chevron button styles (`‹ / ›`, `< / >`, `● / ○`, arrows, bars).
- Separator boundary styles (single dot, double dot, vertical bar, slash, invisible).
- Menu bar item spacing density controls (Compact, Standard, Relaxed).

---

## 🧭 Three-Zone Layout Architecture

Saklamac structures your menu bar into three distinct zones from right to left:

```
┌─────────────────────────────────┬───┬───────────────────────────────┬───┬───┬───────────────────────────┐
│       Ghost Zone (Concealed)    │ ⫶ │    Hidden / Drawer Section    │ • │ ◀ │  Always Visible Section   │
│   (Always hidden from sight)    │   │   (Collapses into the arrow)  │   │   │  (Clock, WiFi, Battery)   │
└─────────────────────────────────┴───┴───────────────────────────────┴───┴───┴───────────────────────────┘
```

1. **Always-Visible Zone** *(Right of `◀`)*: Essential icons that should never be hidden (Clock, Control Center, Battery).
2. **Hidden / Drawer Zone** *(Between `◀` and `•`)*: Secondary icons that toggle in and out of view when you click the arrow or press `⌘⌥H`.
3. **Ghost Zone** *(Left of `⫶`)*: Persistent or noisy utility icons you don't even want in your expanded drawer. Reveal temporarily with `⌥` + Click or `⌘⌥J`.

---

## 🏗️ macOS 27 WindowServer Native Engine

On macOS 27+, status item length inflation is superseded by Apple's unified WindowServer menu bar compositor.

Saklamac Pro resolves this natively:
1. **`MenuBarClientCore.framework` Dynamic Bridge**: Binds to `MBAssessmentModeConfiguration` and `MBAssessmentModeAssertion` at the compositor layer.
2. **`AccessibilityInventory`**: Tracks running application menu bar items and their frames via macOS Accessibility APIs.
3. **Fallback Engine**: Automatically switches to the classic reflow engine on macOS 26 and earlier.

---

## 📦 Installation & Building

### Pre-requisites
- macOS Sonoma (14.0) or newer (macOS 14, 15, and 27+ supported)
- Apple Silicon or Intel Mac
- Command Line Tools: `xcode-select --install`

### Build & Install
Clone the repository and run the build script:

```bash
git clone https://github.com/themanoftalent/saklamac.git
cd saklamac
./build_app.sh
```

To install to your Applications folder:
```bash
cp -R Saklamac.app /Applications/
xattr -cr /Applications/Saklamac.app
open /Applications/Saklamac.app
```

---

## ⚙️ Modern Sidebar Navigation

Access settings at any time by **Right-Clicking** the menu bar icon and selecting **Settings...** (or press `⌘,`):

| Section | Icon | Features |
| :--- | :--- | :--- |
| **Dashboard** | `gauge.medium` | Live telemetry, hardware notch geometry, active engine badge, instant triggers. |
| **App Manager** | `square.stack.3d.up.fill` | Searchable inventory with zone filters and one-click app activations. |
| **Floating Shelf** | `menubar.arrow.down.rectangle` | Secondary dropdown bar configuration for notch overflow protection. |
| **Gestures & Triggers** | `hand.tap.fill` | Hover dwell sliders, scroll wheel toggle, empty click, and auto-hide delay. |
| **Shortcuts & HUD** | `command` | 4 global hotkeys, floating bezel toggle & test, tactile audio effects. |
| **Appearance & Density** | `paintpalette.fill` | 8 icon styles, separator boundary styles, item spacing density. |
| **Profiles & Presets** | `square.stack.3d.forward.dottedline.fill` | Switch configurations (Zen, Work, Presentation), custom profiles, JSON backup. |
| **Pro Features** | `crown.fill` | Ghost Zone guidance, WindowServer native controls, lifetime license. |
| **General Settings** | `gearshape.fill` | Start at login, auto-hide, hover expand. |
| **TheManOfTalent** | `person.crop.circle.fill` | Developer showcase for Mehmet Akif Cifci, brand links, system diagnostics. |

---

## 📜 License & Credits

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

**Developed by Mehmet Akif Cifci | TheManOfTalent**  
Copyright © 2026 Mehmet Akif Cifci (TheManOfTalent). All rights reserved.

---

## ☕ Sponsor or Buy Me a Coffee

If you find this project helpful, consider supporting it or reaching out for collaboration:

[![Buy Me A Coffee](https://img.shields.io/badge/BUY%20ME%20A%20COFFEE-SUPPORT%20PROJECT-green?style=for-the-badge&logo=buymeacoffee)](https://buymeacoffee.com/themanoftalent) [![GitHub Sponsors](https://img.shields.io/badge/SPONSOR-GITHUB%20SPONSORS-ea4aaa?style=for-the-badge&logo=githubsponsors)](https://github.com/sponsors/themanoftalent) [![Let's Connect](https://img.shields.io/badge/LET%27S%20CONNECT-EMAIL-blue?style=for-the-badge&logo=gmail)](mailto:cs.akifcifci@gmail.com)
