import AppKit
import ApplicationServices

public struct MenuBarItemInfo: Equatable, Sendable {
    public let bundleIdentifier: String
    public let appName: String
    public let frame: CGRect

    public init(bundleIdentifier: String, appName: String, frame: CGRect) {
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.frame = frame
    }
}

@MainActor
public final class AccessibilityInventory {
    public static let shared = AccessibilityInventory()

    private init() {}

    public var isAuthorized: Bool {
        return AXIsProcessTrusted()
    }

    public func requestAuthorization() {
        let options = ["AXTrustedCheckOptionPrompt" as CFString: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    public func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    public func snapshot(completion: @escaping @MainActor ([MenuBarItemInfo]) -> Void) {
        guard isAuthorized else {
            completion([])
            return
        }

        let ownPID = ProcessInfo.processInfo.processIdentifier
        let apps = NSWorkspace.shared.runningApplications
            .filter { $0.processIdentifier != ownPID && $0.bundleURL?.pathExtension == "app" }
            .map { (pid: $0.processIdentifier, bundleId: $0.bundleIdentifier, name: $0.localizedName) }

        DispatchQueue.global(qos: .userInitiated).async {
            var results: [MenuBarItemInfo] = []
            for app in apps {
                guard let bundleId = app.bundleId else { continue }
                let appName = app.name ?? bundleId
                let element = AXUIElementCreateApplication(app.pid)
                AXUIElementSetMessagingTimeout(element, 0.1)

                var barValue: CFTypeRef?
                guard AXUIElementCopyAttributeValue(element, "AXExtrasMenuBar" as CFString, &barValue) == .success,
                      let bar = barValue else { continue }

                var childrenValue: CFTypeRef?
                guard AXUIElementCopyAttributeValue(bar as! AXUIElement, kAXChildrenAttribute as CFString, &childrenValue) == .success,
                      let children = childrenValue as? [AXUIElement] else { continue }

                for child in children {
                    if let frame = Self.frame(of: child) {
                        results.append(MenuBarItemInfo(bundleIdentifier: bundleId, appName: appName, frame: frame))
                    }
                }
            }

            Task { @MainActor in
                completion(results)
            }
        }
    }

    private nonisolated static func frame(of element: AXUIElement) -> CGRect? {
        var posValue: CFTypeRef?
        var sizeValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &posValue) == .success,
              AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &sizeValue) == .success else { return nil }

        var pos = CGPoint.zero
        var size = CGSize.zero
        if let p = posValue { AXValueGetValue(p as! AXValue, .cgPoint, &pos) }
        if let s = sizeValue { AXValueGetValue(s as! AXValue, .cgSize, &size) }
        return CGRect(origin: pos, size: size)
    }
}
