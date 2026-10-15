import AppKit
import SwiftUI

@MainActor
public final class FloatingShelfController: ObservableObject {
    public static let shared = FloatingShelfController()

    @Published public private(set) var isVisible: Bool = false
    private var shelfWindow: NSWindow?

    private init() {}

    public func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    public func show() {
        guard let screen = NSScreen.main else { return }

        if shelfWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 54),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.isOpaque = false
            window.backgroundColor = .clear
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
            window.hasShadow = true
            window.contentView = NSHostingView(rootView: FloatingShelfContentView())
            self.shelfWindow = window
        }

        guard let window = shelfWindow else { return }

        // Position directly below menu bar, centered or aligned right
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame
        let menuBarBottom = visibleFrame.origin.y + visibleFrame.height
        let shelfWidth: CGFloat = min(680, screenFrame.width - 40)
        let shelfHeight: CGFloat = 56
        let xPos = (screenFrame.width - shelfWidth) / 2
        let yPos = menuBarBottom - shelfHeight - 8

        window.setFrame(NSRect(x: xPos, y: yPos, width: shelfWidth, height: shelfHeight), display: true)
        window.alphaValue = 0.0
        window.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.22
            window.animator().alphaValue = 1.0
        }

        self.isVisible = true
    }

    public func hide() {
        guard let window = shelfWindow, isVisible else { return }

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.18
            window.animator().alphaValue = 0.0
        }, completionHandler: { [weak self] in
            Task { @MainActor in
                self?.shelfWindow?.orderOut(nil)
                self?.isVisible = false
            }
        })
    }
}

private struct FloatingShelfContentView: View {
    @ObservedObject var prefs = PreferencesManager.shared
    @StateObject private var appState = AppManagerState()

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "menubar.arrow.down.rectangle")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.accentColor)
                Text("Saklamac Shelf")
                    .font(.system(size: 12, weight: .bold))
            }
            .padding(.trailing, 4)

            Divider()
                .frame(height: 24)

            // Running items in shelf
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(appState.apps.prefix(10)) { item in
                        Button(action: {
                            if let app = NSRunningApplication.runningApplications(withBundleIdentifier: item.bundleIdentifier).first {
                                app.activate()
                            }
                        }) {
                            VStack(spacing: 2) {
                                Image(nsImage: item.icon)
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                Text(item.name)
                                    .font(.system(size: 9))
                                    .lineLimit(1)
                                    .foregroundColor(.primary)
                            }
                            .frame(width: 50)
                        }
                        .buttonStyle(.plain)
                        .help("Activate \(item.name)")
                    }
                }
                .padding(.horizontal, 4)
            }

            Spacer()

            Button(action: {
                FloatingShelfController.shared.hide()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Material.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 14, x: 0, y: 6)
        )
    }
}
