import AppKit
import SwiftUI
import Combine

final class PomoPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

@MainActor
public final class PomoPanelController: NSObject, NSWindowDelegate {
    public static let shared = PomoPanelController()

    private var statusItem: NSStatusItem?
    private var panel: NSPanel?
    private var eventMonitor: Any?
    private var timerCancellables = Set<AnyCancellable>()

    public let sessionManager = SessionManager()
    public lazy var timerEngine = TimerEngine(sessionManager: sessionManager)

    private override init() {
        super.init()
    }

    public func setup() {
        setupMainMenu()
        setupStatusItem()
        setupPanel()
        setupHotkeys()
        setupTimerObservations()
        NotificationManager.shared.requestAuthorization()
    }

    // MARK: - Main Menu

    private func setupMainMenu() {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu(title: "pomo")
        appMenu.addItem(withTitle: "Toggle Start/Pause", action: #selector(toggleTimerAction), keyEquivalent: "p")
        if let item = appMenu.items.last {
            item.keyEquivalentModifierMask = [.command, .option]
        }
        appMenu.addItem(withTitle: "Reset Timer", action: #selector(resetTimerAction), keyEquivalent: "r")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit pomo", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        let redoItem = NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        editMenu.addItem(redoItem)
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        let viewMenuItem = NSMenuItem()
        let viewMenu = NSMenu(title: "View")
        viewMenu.addItem(withTitle: "Toggle Theme", action: #selector(toggleThemeAction), keyEquivalent: "d")
        viewMenuItem.submenu = viewMenu
        mainMenu.addItem(viewMenuItem)

        NSApp.mainMenu = mainMenu
    }

    // MARK: - Status Item Setup (Pixel Perfect Icon & Monospaced Typography)

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem?.button else { return }

        updateStatusBarTitle()

        button.target = self
        button.action = #selector(statusItemClicked)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    private func setupTimerObservations() {
        timerEngine.$remainingSeconds
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusBarTitle()
            }
            .store(in: &timerCancellables)

        timerEngine.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusBarTitle()
            }
            .store(in: &timerCancellables)

        timerEngine.$mode
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusBarTitle()
            }
            .store(in: &timerCancellables)
    }

    public func updateStatusBarTitle() {
        guard let button = statusItem?.button else { return }

        let text = timerEngine.menuBarTitle
        let font = NSFont.monospacedDigitSystemFont(ofSize: 12.5, weight: .medium)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.labelColor
        ]

        button.attributedTitle = NSAttributedString(string: " " + text, attributes: attributes)

        // Draw pixel-perfect status dot icon
        let size = NSSize(width: 14, height: 16)
        let image = NSImage(size: size, flipped: false) { _ in
            let isRunning = self.timerEngine.isRunning
            let isRest = self.timerEngine.mode == .rest
            let strokeWidth: CGFloat = 1.2
            let dotRect = NSRect(x: 2.0, y: 4.0, width: 8.0, height: 8.0)
            let insetRect = dotRect.insetBy(dx: strokeWidth / 2, dy: strokeWidth / 2)

            if isRest {
                // Rest period: Concentric ring with inner micro-dot
                let ringPath = NSBezierPath(ovalIn: insetRect)
                ringPath.lineWidth = strokeWidth
                NSColor.labelColor.setStroke()
                ringPath.stroke()

                let innerRect = NSRect(x: 4.75, y: 6.75, width: 2.5, height: 2.5)
                let innerPath = NSBezierPath(ovalIn: innerRect)
                NSColor.labelColor.setFill()
                innerPath.fill()
            } else {
                // Focus: solid filled dot when running, hollow when idle
                if isRunning {
                    let fillPath = NSBezierPath(ovalIn: dotRect)
                    NSColor.labelColor.setFill()
                    fillPath.fill()
                } else {
                    let strokePath = NSBezierPath(ovalIn: insetRect)
                    strokePath.lineWidth = strokeWidth
                    NSColor.labelColor.setStroke()
                    strokePath.stroke()
                }
            }
            return true
        }
        image.isTemplate = true
        button.image = image
        button.imagePosition = .imageLeft
    }

    // MARK: - Panel Setup

    private func setupPanel() {
        let popoverContent = PomoPopoverView(
            timerEngine: timerEngine,
            sessionManager: sessionManager,
            onClose: { [weak self] in
                self?.closeDockedPanel()
            }
        )

        let hostingView = NSHostingView(rootView: popoverContent)

        let panel = PomoPanel(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 250),
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.contentView = hostingView
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.isMovableByWindowBackground = true
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.delegate = self

        self.panel = panel
    }

    private func updatePanelContent() {
        let popoverContent = PomoPopoverView(
            timerEngine: timerEngine,
            sessionManager: sessionManager,
            onClose: { [weak self] in
                self?.closeDockedPanel()
            }
        )
        panel?.contentView = NSHostingView(rootView: popoverContent)
    }

    // MARK: - Hotkeys

    private func setupHotkeys() {
        GlobalHotkeyManager.shared.setup(
            onToggleTimer: { [weak self] in
                self?.timerEngine.togglePlayPause()
            },
            onResetTimer: { [weak self] in
                self?.timerEngine.reset()
            },
            onSelectFocus: { [weak self] in
                self?.timerEngine.switchMode(to: .focus)
            },
            onSelectRest: { [weak self] in
                self?.timerEngine.switchMode(to: .rest)
            },
            onClosePanel: { [weak self] in
                self?.closeDockedPanel()
            }
        )
    }

    // MARK: - Actions

    @objc private func toggleTimerAction() {
        timerEngine.togglePlayPause()
    }

    @objc private func resetTimerAction() {
        timerEngine.reset()
    }

    @objc private func toggleThemeAction() {
        let current = UserDefaults.standard.string(forKey: "appTheme") ?? "system"
        let next: String
        switch current {
        case "dark": next = "light"
        case "light": next = "system"
        default: next = "dark"
        }
        UserDefaults.standard.set(next, forKey: "appTheme")
        updatePanelContent()
    }

    @objc private func statusItemClicked() {
        toggleDockedPanel()
    }

    private func toggleDockedPanel() {
        guard let panel = panel, let button = statusItem?.button else { return }

        if panel.isVisible {
            closeDockedPanel()
        } else {
            showDockedPanel(relativeTo: button)
        }
    }

    private func showDockedPanel(relativeTo button: NSStatusBarButton) {
        guard let panel = panel else { return }

        let buttonFrame = button.window?.convertToScreen(button.frame) ?? .zero
        let panelWidth = panel.frame.width
        let x = buttonFrame.midX - (panelWidth / 2)
        let y = buttonFrame.minY - panel.frame.height - 4

        panel.setFrameOrigin(NSPoint(x: max(10, x), y: y))
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self = self else { return }
            if let panel = self.panel, panel.isVisible {
                let mouseLocation = NSEvent.mouseLocation
                if !panel.frame.contains(mouseLocation) {
                    self.closeDockedPanel()
                }
            }
        }
    }

    public func closeDockedPanel() {
        panel?.orderOut(nil)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
