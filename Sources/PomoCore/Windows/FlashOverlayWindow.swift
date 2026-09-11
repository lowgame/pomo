import AppKit

@MainActor
public final class FlashOverlayWindow: NSWindow {
    public init() {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .statusBar + 1
        self.ignoresMouseEvents = true
        self.hasShadow = false
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        let flashBar = NSBox()
        flashBar.boxType = .custom
        flashBar.borderWidth = 0
        flashBar.fillColor = .white
        flashBar.translatesAutoresizingMaskIntoConstraints = false
        self.contentView = flashBar
    }

    public func flash() {
        guard let screen = NSScreen.main else { return }
        // 2px micro-rim across top edge of screen
        let screenFrame = screen.frame
        let height: CGFloat = 2.0
        let rect = NSRect(x: screenFrame.minX, y: screenFrame.maxY - height, width: screenFrame.width, height: height)
        self.setFrame(rect, display: true)

        self.alphaValue = 0.0
        self.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.06
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().alphaValue = 1.0
        }, completionHandler: {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.24
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                self.animator().alphaValue = 0.0
            }, completionHandler: {
                self.orderOut(nil)
            })
        })
    }
}

@MainActor
public final class FlashEffectManager {
    public static let shared = FlashEffectManager()
    private var window: FlashOverlayWindow?

    private init() {}

    public func triggerFlash() {
        if window == nil {
            window = FlashOverlayWindow()
        }
        window?.flash()
    }
}
