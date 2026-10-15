import AppKit

public final class AppDelegate: NSObject, NSApplicationDelegate {
    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("Saklamac: Launching application...")

        // Ensure status bar items and hotkeys are initialized
        _ = MenuBarController.shared
        _ = HotKeyManager.shared

        // If first launch, show onboarding window
        if !PreferencesManager.shared.hasSeenWelcome {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                WindowManager.shared.showOnboardingWindow()
            }
        }
    }

    public func applicationWillTerminate(_ notification: Notification) {
        HotKeyManager.shared.unregisterAll()
    }

    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            WindowManager.shared.showSettingsWindow()
        }
        return true
    }
}
