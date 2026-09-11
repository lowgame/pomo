#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DIR"

echo "=== pomo Minimalist Glowish Sliced Circle İkonu Üretiliyor ==="

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

// Specular micro-rim around macOS squircle
let rimPath = NSBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), xRadius: 226, yRadius: 226)
rimPath.lineWidth = 2.5
NSColor(white: 1.0, alpha: 0.12).setStroke()
rimPath.stroke()

let center = CGPoint(x: size / 2, y: size / 2)
let radius: CGFloat = 280

// 2. Radiant Atmospheric Background Bloom (Radial Glow starting at 0.0)
let colorSpace = CGColorSpaceCreateDeviceRGB()
let glowColors = [
    NSColor(white: 1.0, alpha: 0.28).cgColor,
    NSColor(white: 1.0, alpha: 0.14).cgColor,
    NSColor(white: 1.0, alpha: 0.04).cgColor,
    NSColor(white: 0.0, alpha: 0.0).cgColor
] as CFArray
let glowLocations: [CGFloat] = [0.0, 0.40, 0.70, 1.0]
if let radialGradient = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: glowLocations) {
    cg.saveGState()
    cg.drawRadialGradient(
        radialGradient,
        startCenter: center,
        startRadius: 0.0,
        endCenter: center,
        endRadius: radius * 1.6,
        options: []
    )
    cg.restoreGState()
}

// 3. Construct Sliced Circle Geometry (60-degree slice missing near 12 o'clock)
let cutStart: CGFloat = 85.0 * .pi / 180.0  // near 12 o'clock
let cutEnd: CGFloat = 25.0 * .pi / 180.0    // near 2 o'clock

let pStart = CGPoint(x: center.x + radius * cos(cutStart), y: center.y + radius * sin(cutStart))
let pEnd = CGPoint(x: center.x + radius * cos(cutEnd), y: center.y + radius * sin(cutEnd))

let slicedPath = CGMutablePath()
slicedPath.move(to: center)
slicedPath.addLine(to: pStart)
slicedPath.addArc(center: center, radius: radius, startAngle: cutStart, endAngle: cutEnd, clockwise: false)
slicedPath.addLine(to: center)
slicedPath.closeSubpath()

// 4. Multi-tier Gaussian Glow (Bloom)
let bloomPasses: [(blur: CGFloat, alpha: CGFloat)] = [
    (140.0, 0.16),
    (80.0, 0.26),
    (40.0, 0.45),
    (18.0, 0.70),
    (6.0, 0.95)
]

for pass in bloomPasses {
    cg.saveGState()
    cg.setShadow(
        offset: .zero,
        blur: pass.blur,
        color: NSColor(white: 1.0, alpha: pass.alpha).cgColor
    )
    cg.addPath(slicedPath)
    cg.setFillColor(NSColor(white: 1.0, alpha: 0.35).cgColor)
    cg.fillPath()
    cg.restoreGState()
}

// 5. Core Luminous Body (Pure White with Subtle Vignelli Gradient)
cg.saveGState()
cg.addPath(slicedPath)
cg.clip()

let coreColors = [
    NSColor(white: 1.0, alpha: 1.0).cgColor,
    NSColor(white: 0.94, alpha: 1.0).cgColor
] as CFArray
if let coreGrad = CGGradient(colorsSpace: colorSpace, colors: coreColors, locations: [0.0, 1.0]) {
    cg.drawLinearGradient(
        coreGrad,
        start: CGPoint(x: center.x, y: center.y + radius),
        end: CGPoint(x: center.x, y: center.y - radius),
        options: []
    )
}
cg.restoreGState()

// 6. Intense Razor-Sharp Glowing Edge Stroke
cg.saveGState()
cg.addPath(slicedPath)
cg.setStrokeColor(NSColor.white.cgColor)
cg.setLineWidth(2.5)
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
