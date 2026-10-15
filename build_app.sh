#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Saklamac.app"
APP_DIR="$DIR/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "=== Building Saklamac (Release) ==="
cd "$DIR"
swift build -c release

RELEASE_BIN="$DIR/.build/out/Products/Release/Saklamac"
if [ ! -f "$RELEASE_BIN" ]; then
    RELEASE_BIN="$DIR/.build/release/Saklamac"
fi

if [ ! -f "$RELEASE_BIN" ]; then
    echo "Error: Release binary not found at $RELEASE_BIN"
    exit 1
fi

echo "=== Creating Saklamac.app bundle ==="
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

cp "$RELEASE_BIN" "$MACOS_DIR/Saklamac"
chmod +x "$MACOS_DIR/Saklamac"

echo "=== Creating Info.plist ==="
cat << 'EOF' > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Saklamac</string>
    <key>CFBundleIdentifier</key>
    <string>com.saklamac.app</string>
    <key>CFBundleName</key>
    <string>Saklamac</string>
    <key>CFBundleDisplayName</key>
    <string>Saklamac Pro</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 Mehmet Akif Cifci (TheManOfTalent). All rights reserved.</string>
</dict>
</plist>
EOF

echo "=== Generating High-Resolution App Icon ==="
ICONSET_DIR="/tmp/Saklamac.iconset"
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

cat << 'SWIFTEOF' > /tmp/generate_saklamac_icon.swift
import AppKit

let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()

let ctx = NSGraphicsContext.current?.cgContext

// 1. Squircle background
let squircleRect = NSRect(x: 100, y: 100, width: 824, height: 824)
let path = NSBezierPath(roundedRect: squircleRect, xRadius: 185, yRadius: 185)

let bgGradient = NSGradient(
    starting: NSColor(red: 0.08, green: 0.12, blue: 0.22, alpha: 1.0),
    ending: NSColor(red: 0.04, green: 0.06, blue: 0.12, alpha: 1.0)
)
bgGradient?.draw(in: path, angle: -45)

// Outer border
NSColor(white: 1.0, alpha: 0.12).setStroke()
path.lineWidth = 8
path.stroke()

// 2. Subtle radial glow behind center
let glowRect = NSRect(x: 262, y: 262, width: 500, height: 500)
let glowPath = NSBezierPath(ovalIn: glowRect)
NSColor(red: 0.95, green: 0.55, blue: 0.15, alpha: 0.15).setFill()
glowPath.fill()

// 3. Simulated Menu Bar Glass Strip
let barRect = NSRect(x: 180, y: 560, width: 664, height: 120)
let barPath = NSBezierPath(roundedRect: barRect, xRadius: 28, yRadius: 28)
let barGradient = NSGradient(
    starting: NSColor(white: 1.0, alpha: 0.18),
    ending: NSColor(white: 1.0, alpha: 0.06)
)
barGradient?.draw(in: barPath, angle: -90)
NSColor(white: 1.0, alpha: 0.25).setStroke()
barPath.lineWidth = 3
barPath.stroke()

// Hidden Pocket Shading (left section inside bar)
let pocketRect = NSRect(x: 185, y: 565, width: 280, height: 110)
let pocketPath = NSBezierPath(roundedRect: pocketRect, xRadius: 24, yRadius: 24)
NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.35).setFill()
pocketPath.fill()

// Status Dots inside the pocket (partially concealed)
let dotColors: [NSColor] = [
    NSColor(red: 0.30, green: 0.65, blue: 1.0, alpha: 0.5),
    NSColor(red: 0.85, green: 0.35, blue: 0.9, alpha: 0.5),
    NSColor(red: 0.20, green: 0.80, blue: 0.5, alpha: 0.5)
]
for (idx, color) in dotColors.enumerated() {
    let dx = 240.0 + CGFloat(idx) * 65.0
    let dot = NSBezierPath(ovalIn: NSRect(x: dx, y: 605, width: 30, height: 30))
    color.setFill()
    dot.fill()
}

// Separator Dot
let sepDot = NSBezierPath(ovalIn: NSRect(x: 485, y: 610, width: 20, height: 20))
NSColor(white: 1.0, alpha: 0.9).setFill()
sepDot.fill()

// Chevron Icon (<)
let chevron = NSBezierPath()
chevron.lineWidth = 14
chevron.lineCapStyle = .round
chevron.lineJoinStyle = .round
chevron.move(to: NSPoint(x: 580, y: 648))
chevron.line(to: NSPoint(x: 550, y: 620))
chevron.line(to: NSPoint(x: 580, y: 592))
let chevronGrad = NSGradient(
    starting: NSColor(red: 1.0, green: 0.72, blue: 0.25, alpha: 1.0),
    ending: NSColor(red: 0.95, green: 0.45, blue: 0.15, alpha: 1.0)
)
NSColor(red: 1.0, green: 0.65, blue: 0.2, alpha: 1.0).setStroke()
chevron.stroke()

// Visible Status Icons (right side)
let visDots: [NSColor] = [
    NSColor(white: 1.0, alpha: 0.95),
    NSColor(white: 1.0, alpha: 0.95),
    NSColor(white: 1.0, alpha: 0.95)
]
for (idx, color) in visDots.enumerated() {
    let dx = 650.0 + CGFloat(idx) * 55.0
    let dot = NSBezierPath(ovalIn: NSRect(x: dx, y: 607, width: 26, height: 26))
    color.setFill()
    dot.fill()
}

// 4. "PRO" Golden Badge Pill in lower section
let badgeRect = NSRect(x: 412, y: 280, width: 200, height: 60)
let badgePath = NSBezierPath(roundedRect: badgeRect, xRadius: 30, yRadius: 30)
let badgeGrad = NSGradient(
    starting: NSColor(red: 1.0, green: 0.80, blue: 0.30, alpha: 1.0),
    ending: NSColor(red: 0.95, green: 0.50, blue: 0.10, alpha: 1.0)
)
badgeGrad?.draw(in: badgePath, angle: -45)

let proAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 32, weight: .black),
    .foregroundColor: NSColor(red: 0.1, green: 0.05, blue: 0.0, alpha: 1.0)
]
let proStr = NSAttributedString(string: "PRO", attributes: proAttrs)
let proSize = proStr.size()
proStr.draw(at: NSPoint(x: badgeRect.midX - proSize.width / 2, y: badgeRect.midY - proSize.height / 2 + 2))

// App Title below
let titleAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 42, weight: .bold),
    .foregroundColor: NSColor.white
]
let titleStr = NSAttributedString(string: "SAKLAMAC", attributes: titleAttrs)
let titleSize = titleStr.size()
titleStr.draw(at: NSPoint(x: 512 - titleSize.width / 2, y: 380))

image.unlockFocus()

if let tiff = image.tiffRepresentation,
   let rep = NSBitmapImageRep(data: tiff),
   let png = rep.representation(using: .png, properties: [:]) {
    try? png.write(to: URL(fileURLWithPath: "/tmp/saklamac_1024.png"))
}
SWIFTEOF

swift /tmp/generate_saklamac_icon.swift

# Generate standard iconset sizes
sips -z 16 16     /tmp/saklamac_1024.png --out "$ICONSET_DIR/icon_16x16.png" > /dev/null
sips -z 32 32     /tmp/saklamac_1024.png --out "$ICONSET_DIR/icon_16x16@2x.png" > /dev/null
sips -z 32 32     /tmp/saklamac_1024.png --out "$ICONSET_DIR/icon_32x32.png" > /dev/null
sips -z 64 64     /tmp/saklamac_1024.png --out "$ICONSET_DIR/icon_32x32@2x.png" > /dev/null
sips -z 128 128   /tmp/saklamac_1024.png --out "$ICONSET_DIR/icon_128x128.png" > /dev/null
sips -z 256 256   /tmp/saklamac_1024.png --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null
sips -z 256 256   /tmp/saklamac_1024.png --out "$ICONSET_DIR/icon_256x256.png" > /dev/null
sips -z 512 512   /tmp/saklamac_1024.png --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null
sips -z 512 512   /tmp/saklamac_1024.png --out "$ICONSET_DIR/icon_512x512.png" > /dev/null
cp /tmp/saklamac_1024.png "$ICONSET_DIR/icon_512x512@2x.png"

iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"
rm -rf "$ICONSET_DIR" /tmp/generate_saklamac_icon.swift /tmp/saklamac_1024.png

echo "=== Ad-hoc Signing Saklamac.app ==="
codesign --force --deep -s - "$APP_DIR"

echo "=== Saklamac.app successfully built and packaged at: ==="
echo "$APP_DIR"
