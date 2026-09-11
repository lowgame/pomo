#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DIR"

echo "=== pomo Ultra-Glowish Sliced Circle İkonu Üretiliyor ==="

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
let cg = context.cgContext

let rect = NSRect(x: 0, y: 0, width: size, height: size)

// 1. Deep Pitch Black Background (#000000)
let bgPath = NSBezierPath(roundedRect: rect, xRadius: 228, yRadius: 228)
NSColor.black.setFill()
bgPath.fill()

let rimPath = NSBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), xRadius: 226, yRadius: 226)
rimPath.lineWidth = 2.0
NSColor(white: 1.0, alpha: 0.12).setStroke()
rimPath.stroke()

let center = CGPoint(x: size / 2, y: size / 2)
let radius: CGFloat = 280

// 2. Deep Ethereal Ambient Radial Glow
let colorSpace = CGColorSpaceCreateDeviceRGB()
let glowColors = [
    NSColor(white: 1.0, alpha: 0.28).cgColor,
    NSColor(white: 1.0, alpha: 0.16).cgColor,
    NSColor(white: 1.0, alpha: 0.05).cgColor,
    NSColor(white: 0.0, alpha: 0.0).cgColor
] as CFArray
let glowLocations: [CGFloat] = [0.0, 0.35, 0.65, 1.0]
if let radialGradient = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: glowLocations) {
    cg.saveGState()
    cg.drawRadialGradient(
        radialGradient,
        startCenter: center,
        startRadius: 0.0,
        endCenter: center,
        endRadius: radius * 1.55,
        options: []
    )
    cg.restoreGState()
}

// 3. Sliced Circle Path (60-degree slice carved out to the center)
let cutStart: CGFloat = 85.0 * .pi / 180.0
let cutEnd: CGFloat = 25.0 * .pi / 180.0

let pStart = CGPoint(x: center.x + radius * cos(cutStart), y: center.y + radius * sin(cutStart))
let pEnd = CGPoint(x: center.x + radius * cos(cutEnd), y: center.y + radius * sin(cutEnd))

let wedgePath = CGMutablePath()
wedgePath.move(to: center)
wedgePath.addLine(to: pStart)
wedgePath.addArc(center: center, radius: radius, startAngle: cutStart, endAngle: cutEnd, clockwise: false)
wedgePath.addLine(to: center)
wedgePath.closeSubpath()

// 4. Multi-tier Physical Gaussian Glow (Matching the user's reference photo)
let glowPasses: [(lineWidth: CGFloat, blur: CGFloat, alpha: CGFloat)] = [
    (32.0, 180.0, 0.25),
    (28.0, 110.0, 0.35),
    (24.0, 60.0, 0.55),
    (20.0, 28.0, 0.75),
    (16.0, 12.0, 0.90),
    (12.0, 4.0, 1.0)
]

for pass in glowPasses {
    cg.saveGState()
    cg.setLineJoin(.round)
    cg.setLineCap(.round)
    cg.setLineWidth(pass.lineWidth)
    cg.setShadow(
        offset: .zero,
        blur: pass.blur,
        color: NSColor(white: 1.0, alpha: pass.alpha).cgColor
    )
    cg.addPath(wedgePath)
    cg.setStrokeColor(NSColor(white: 1.0, alpha: pass.alpha).cgColor)
    cg.strokePath()
    cg.restoreGState()
}

// 5. Crisp Brilliant White Core Filament (10pt stroke with rounded joints)
cg.saveGState()
cg.setLineJoin(.round)
cg.setLineCap(.round)
cg.setLineWidth(10.0)
cg.addPath(wedgePath)
cg.setStrokeColor(NSColor.white.cgColor)
cg.strokePath()
cg.restoreGState()

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

echo "Tamamlandı: Resources/AppIcon.icns güncellendi."
