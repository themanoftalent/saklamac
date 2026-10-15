import AppKit
import SwiftUI

@MainActor
public final class QuickSearchController: ObservableObject {
    public static let shared = QuickSearchController()

    @Published public private(set) var isVisible: Bool = false
    private var searchWindow: NSWindow?

    private init() {}

    public func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    public func show() {
        if searchWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 380),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.isOpaque = false
            window.backgroundColor = .clear
            window.level = .floating
            window.center()
            window.hasShadow = true
            window.collectionBehavior = [.canJoinAllSpaces, .stationary]
            window.contentView = NSHostingView(rootView: QuickSearchHUDView())
            self.searchWindow = window
        }

        guard let window = searchWindow else { return }
        window.center()
        window.alphaValue = 0.0
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            window.animator().alphaValue = 1.0
        }

        self.isVisible = true
    }

    public func hide() {
        guard let window = searchWindow, isVisible else { return }

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.15
            window.animator().alphaValue = 0.0
        }, completionHandler: { [weak self] in
            Task { @MainActor in
                self?.searchWindow?.orderOut(nil)
                self?.isVisible = false
            }
        })
    }
}

@MainActor
public final class QuickSearchState: ObservableObject {
    @Published public var query: String = ""
    public init() {}
}

private struct QuickSearchHUDView: View {
    @StateObject private var appState = AppManagerState()
    @StateObject private var searchState = QuickSearchState()

    private var results: [AppManagerItem] {
        if searchState.query.trimmingCharacters(in: .whitespaces).isEmpty {
            return appState.apps
        }
        let q = searchState.query.lowercased()
        return appState.apps.filter {
            $0.name.lowercased().contains(q) || $0.bundleIdentifier.lowercased().contains(q)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)

                TextField("Search menu bar apps...", text: $searchState.query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))

                if !searchState.query.isEmpty {
                    Button(action: { searchState.query = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Button(action: { QuickSearchController.shared.hide() }) {
                    Text("esc")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(4)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(16)

            Divider()

            // Results List
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(results) { item in
                        QuickSearchRowView(item: item)
                    }
                }
                .padding(12)
            }
        }
        .frame(width: 500, height: 380)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Material.ultraThickMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.35), radius: 24, x: 0, y: 10)
        )
    }
}

private struct QuickSearchRowView: View {
    let item: AppManagerItem

    var body: some View {
        Button(action: {
            if let app = NSRunningApplication.runningApplications(withBundleIdentifier: item.bundleIdentifier).first {
                app.activate()
            }
            QuickSearchController.shared.hide()
        }) {
            HStack(spacing: 12) {
                Image(nsImage: item.icon)
                    .resizable()
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                    Text(item.bundleIdentifier)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                Spacer()

                let zone = PreferencesManager.shared.getCustomZone(for: item.bundleIdentifier) ?? .hidden
                Text(zone.title)
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundColor(.accentColor)
                    .cornerRadius(4)

                Image(systemName: "arrow.turn.down.left")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.06))
            )
        }
        .buttonStyle(.plain)
    }
}

