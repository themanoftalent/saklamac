import AppKit
import SwiftUI

@MainActor
public final class WindowManager {
    public static let shared = WindowManager()

    private var settingsWindow: NSWindow?
    private var onboardingWindow: NSWindow?

    private init() {}

    public var isAnyWindowVisible: Bool {
        let settingsVisible = settingsWindow?.isVisible ?? false
        let onboardingVisible = onboardingWindow?.isVisible ?? false
        return settingsVisible || onboardingVisible
    }

    public func showSettingsWindow(selectedTab: SettingsTab = .dashboard) {
        if settingsWindow == nil {
            let view = SettingsView(selectedTab: selectedTab)
            let hosting = NSHostingView(rootView: view)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 820, height: 580),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "Saklamac Pro — by TheManOfTalent"
            window.minSize = NSSize(width: 740, height: 520)
            window.center()
            window.contentView = hosting
            window.isReleasedWhenClosed = false
            window.titlebarAppearsTransparent = false

            settingsWindow = window
        } else if let hosting = settingsWindow?.contentView as? NSHostingView<SettingsView> {
            hosting.rootView = SettingsView(selectedTab: selectedTab)
        }

        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    public func showAboutWindow() {
        showSettingsWindow(selectedTab: .about)
    }

    public func showOnboardingWindow() {
        if onboardingWindow == nil {
            let view = OnboardingView { [weak self] in
                self?.onboardingWindow?.close()
                PreferencesManager.shared.hasSeenWelcome = true
            }
            let hosting = NSHostingView(rootView: view)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 580, height: 500),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "Welcome to Saklamac"
            window.center()
            window.contentView = hosting
            window.isReleasedWhenClosed = false

            onboardingWindow = window
        }

        NSApp.activate(ignoringOtherApps: true)
        onboardingWindow?.makeKeyAndOrderFront(nil)
    }
}
