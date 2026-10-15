import Foundation
import ServiceManagement

@MainActor
public final class LaunchAtLoginManager {
    public static let shared = LaunchAtLoginManager()

    private init() {}

    public var isEnabled: Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }

    public func setLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    if SMAppService.mainApp.status != .enabled {
                        try SMAppService.mainApp.register()
                        NSLog("LaunchAtLogin: Registered successfully")
                    }
                } else {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                        NSLog("LaunchAtLogin: Unregistered successfully")
                    }
                }
            } catch {
                NSLog("LaunchAtLogin: Failed with error: \(error.localizedDescription)")
            }
        }
    }
}
