#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DIR"

echo "=== pomo Minimalist İkonu Üretiliyor ==="

swift - << 'SWIFT'
import AppKit

let size: CGFloat = 1024
let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(size),
    pixelsHigh: Int(size),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
)!

NSGraphicsContext.saveGraphicsState()
let context = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current = context

let rect = NSRect(x: 0, y: 0, width: size, height: size)

// 1. Pure Black Background with rounded squircle
let bgPath = NSBezierPath(roundedRect: rect, xRadius: 228, yRadius: 228)
NSColor(calibratedRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).setFill()
bgPath.fill()

// Subtle inner border (Liquid Glass micro-rim)
let rimPath = NSBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), xRadius: 226, yRadius: 226)
rimPath.lineWidth = 3
NSColor(calibratedWhite: 1.0, alpha: 0.12).setStroke()
rimPath.stroke()

// 2. Minimalist Timer Dial Geometry (Massimo Vignelli inspired)
let center = NSPoint(x: size / 2, y: size / 2)
let radius: CGFloat = 310

// Outer subtle circle track (#8E8E93 at 25% opacity)
let trackPath = NSBezierPath()
trackPath.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
trackPath.lineWidth = 14
NSColor(calibratedWhite: 0.55, alpha: 0.25).setStroke()
trackPath.stroke()

// Active Pomodoro Arc (Top 12 o'clock, 25 minutes = 150 degrees clockwise)
// In macOS standard coordinates, 90 is top (12 o'clock). 25 min = 150 deg clockwise -> 90 to -60 (300)
let arcPath = NSBezierPath()
arcPath.appendArc(withCenter: center, radius: radius, startAngle: 90, endAngle: 300, clockwise: true)
arcPath.lineWidth = 36
arcPath.lineCapStyle = .round
NSColor.white.setStroke()
arcPath.stroke()

// 3. Center Focus Dot (pure white minimalist dot)
let centerDotRadius: CGFloat = 42
let centerDotRect = NSRect(
    x: center.x - centerDotRadius,
    y: center.y - centerDotRadius,
    width: centerDotRadius * 2,
    height: centerDotRadius * 2
)
let centerDotPath = NSBezierPath(ovalIn: centerDotRect)
NSColor.white.setFill()
centerDotPath.fill()

// 4. 12 o'clock Apex Precision Marker
let markerRadius: CGFloat = 16
let markerCenter = NSPoint(x: center.x, y: center.y + radius)
let markerRect = NSRect(
    x: markerCenter.x - markerRadius,
    y: markerCenter.y - markerRadius,
    width: markerRadius * 2,
    height: markerRadius * 2
)
let markerPath = NSBezierPath(ovalIn: markerRect)
NSColor.white.setFill()
markerPath.fill()

NSGraphicsContext.restoreGraphicsState()

let pngData = rep.representation(using: .png, properties: [:])!
try! pngData.write(to: URL(fileURLWithPath: "Resources/app_icon_1024.png"))
SWIFT

mkdir -p build/pomo.iconset
sips -z 16 16     Resources/app_icon_1024.png --out build/pomo.iconset/icon_16x16.png > /dev/null
sips -z 32 32     Resources/app_icon_1024.png --out build/pomo.iconset/icon_16x16@2x.png > /dev/null
sips -z 32 32     Resources/app_icon_1024.png --out build/pomo.iconset/icon_32x32.png > /dev/null
sips -z 64 64     Resources/app_icon_1024.png --out build/pomo.iconset/icon_32x32@2x.png > /dev/null
sips -z 128 128   Resources/app_icon_1024.png --out build/pomo.iconset/icon_128x128.png > /dev/null
sips -z 256 256   Resources/app_icon_1024.png --out build/pomo.iconset/icon_128x128@2x.png > /dev/null
sips -z 256 256   Resources/app_icon_1024.png --out build/pomo.iconset/icon_256x256.png > /dev/null
sips -z 512 512   Resources/app_icon_1024.png --out build/pomo.iconset/icon_256x256@2x.png > /dev/null
sips -z 512 512   Resources/app_icon_1024.png --out build/pomo.iconset/icon_512x512.png > /dev/null
sips -z 1024 1024 Resources/app_icon_1024.png --out build/pomo.iconset/icon_512x512@2x.png > /dev/null

iconutil -c icns build/pomo.iconset -o Resources/AppIcon.icns
rm -rf build/pomo.iconset

echo "Tamamlandı: Resources/AppIcon.icns oluşturuldu."
