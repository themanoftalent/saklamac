import AppKit
import SwiftUI

@MainActor
public final class HUDController {
    public static let shared = HUDController()

    private var hudWindow: NSWindow?
    private var fadeTimer: Timer?

    private init() {}

    public func show(message: String, systemImage: String) {
        fadeTimer?.invalidate()

        if hudWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 220, height: 64),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.isOpaque = false
            window.backgroundColor = .clear
            window.level = .floating
            window.ignoresMouseEvents = true
            window.collectionBehavior = [.canJoinAllSpaces, .stationary]
            hudWindow = window
        }

        let hudView = HUDView(message: message, systemImage: systemImage)
        hudWindow?.contentView = NSHostingView(rootView: hudView)

        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let x = screenRect.midX - 110
            let y = screenRect.maxY - 80
            hudWindow?.setFrameOrigin(NSPoint(x: x, y: y))
        }

        hudWindow?.alphaValue = 0.0
        hudWindow?.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            hudWindow?.animator().alphaValue = 1.0
        }

        fadeTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.dismiss()
            }
        }
    }

    public func dismiss() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            self.hudWindow?.animator().alphaValue = 0.0
        }, completionHandler: { [weak self] in
            Task { @MainActor in
                self?.hudWindow?.orderOut(nil)
            }
        })
    }
}

private struct HUDView: View {
    let message: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.accentColor)

            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(width: 220, height: 54)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
