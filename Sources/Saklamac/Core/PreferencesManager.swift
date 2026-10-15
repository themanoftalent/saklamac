import Foundation
import SwiftUI
import Combine

@MainActor
public final class PreferencesManager: ObservableObject {
    public static let shared = PreferencesManager()

    private let defaults = UserDefaults.standard

    // Developer & Brand Credits
    public let companyName = "SoftAI Yazılım"
    public let developerTitle = "Assoc. Prof. Dr. Mehmet Akif Cifci"
    public let developerName = "Assoc. Prof. Dr. Mehmet Akif Cifci"
    public let developerBrand = "TheManOfTalent"
    public let developerCredit = "Developed by Assoc. Prof. Dr. Mehmet Akif Cifci | SoftAI Yazılım"
    public let githubUsername = "@themanoftalent"
    public let githubURL = "https://github.com/themanoftalent/saklamac"
    public let portfolioURL = "https://github.com/themanoftalent"
    public let sponsorURL = "https://github.com/sponsors/themanoftalent"
    public let buyMeACoffeeURL = "https://buymeacoffee.com/themanoftalent"

    private enum Keys {
        static let launchAtLogin = "launchAtLogin"
        static let autoCollapseEnabled = "autoCollapseEnabled"
        static let autoCollapseDelay = "autoCollapseDelay"
        static let hideSeparatorWhenCollapsed = "hideSeparatorWhenCollapsed"
        static let alwaysHiddenEnabled = "alwaysHiddenEnabled"
        static let hoverToExpand = "hoverToExpand"
        static let hoverDwellTime = "hoverDwellTime"
        static let playSoundOnToggle = "playSoundOnToggle"
        static let expandSound = "expandSound"
        static let collapseSound = "collapseSound"
        static let showHUDNotifications = "showHUDNotifications"
        static let iconStyle = "iconStyle"
        static let separatorStyle = "separatorStyle"
        static let toggleShortcut = "toggleShortcut"
        static let alwaysHiddenShortcut = "alwaysHiddenShortcut"
        static let searchShortcut = "searchShortcut"
        static let shelfShortcut = "shelfShortcut"
        static let scrollGestureEnabled = "scrollGestureEnabled"
        static let emptyClickGestureEnabled = "emptyClickGestureEnabled"
        static let notchAwarenessEnabled = "notchAwarenessEnabled"
        static let menuBarSpacing = "menuBarSpacing"
        static let isProActivated = "isProActivated"
        static let hasSeenWelcome = "hasSeenWelcome"
        static let customAppZones = "customAppZones"
    }

    @Published public var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            LaunchAtLoginManager.shared.setLaunchAtLogin(enabled: launchAtLogin)
        }
    }

    @Published public var autoCollapseEnabled: Bool {
        didSet { defaults.set(autoCollapseEnabled, forKey: Keys.autoCollapseEnabled) }
    }

    @Published public var autoCollapseDelay: Double {
        didSet { defaults.set(autoCollapseDelay, forKey: Keys.autoCollapseDelay) }
    }

    @Published public var hideSeparatorWhenCollapsed: Bool {
        didSet {
            defaults.set(hideSeparatorWhenCollapsed, forKey: Keys.hideSeparatorWhenCollapsed)
            NotificationCenter.default.post(name: .appearanceSettingsChanged, object: nil)
        }
    }

    @Published public var alwaysHiddenEnabled: Bool {
        didSet {
            defaults.set(alwaysHiddenEnabled, forKey: Keys.alwaysHiddenEnabled)
            NotificationCenter.default.post(name: .alwaysHiddenSettingsChanged, object: nil)
        }
    }

    @Published public var hoverToExpand: Bool {
        didSet {
            defaults.set(hoverToExpand, forKey: Keys.hoverToExpand)
            NotificationCenter.default.post(name: .hoverSettingsChanged, object: nil)
        }
    }

    @Published public var hoverDwellTime: Double {
        didSet { defaults.set(hoverDwellTime, forKey: Keys.hoverDwellTime) }
    }

    @Published public var playSoundOnToggle: Bool {
        didSet { defaults.set(playSoundOnToggle, forKey: Keys.playSoundOnToggle) }
    }

    @Published public var expandSound: SoundEffect {
        didSet { defaults.set(expandSound.rawValue, forKey: Keys.expandSound) }
    }

    @Published public var collapseSound: SoundEffect {
        didSet { defaults.set(collapseSound.rawValue, forKey: Keys.collapseSound) }
    }

    @Published public var showHUDNotifications: Bool {
        didSet { defaults.set(showHUDNotifications, forKey: Keys.showHUDNotifications) }
    }

    @Published public var iconStyle: IconStyle {
        didSet {
            defaults.set(iconStyle.rawValue, forKey: Keys.iconStyle)
            NotificationCenter.default.post(name: .appearanceSettingsChanged, object: nil)
        }
    }

    @Published public var separatorStyle: SeparatorStyle {
        didSet {
            defaults.set(separatorStyle.rawValue, forKey: Keys.separatorStyle)
            NotificationCenter.default.post(name: .appearanceSettingsChanged, object: nil)
        }
    }

    @Published public var toggleShortcut: KeyCombo? {
        didSet {
            if let toggleShortcut = toggleShortcut, let data = try? JSONEncoder().encode(toggleShortcut) {
                defaults.set(data, forKey: Keys.toggleShortcut)
            } else {
                defaults.removeObject(forKey: Keys.toggleShortcut)
            }
            NotificationCenter.default.post(name: .hotKeySettingsChanged, object: nil)
        }
    }

    @Published public var alwaysHiddenShortcut: KeyCombo? {
        didSet {
            if let alwaysHiddenShortcut = alwaysHiddenShortcut, let data = try? JSONEncoder().encode(alwaysHiddenShortcut) {
                defaults.set(data, forKey: Keys.alwaysHiddenShortcut)
            } else {
                defaults.removeObject(forKey: Keys.alwaysHiddenShortcut)
            }
            NotificationCenter.default.post(name: .hotKeySettingsChanged, object: nil)
        }
    }

    @Published public var searchShortcut: KeyCombo? {
        didSet {
            if let searchShortcut = searchShortcut, let data = try? JSONEncoder().encode(searchShortcut) {
                defaults.set(data, forKey: Keys.searchShortcut)
            } else {
                defaults.removeObject(forKey: Keys.searchShortcut)
            }
            NotificationCenter.default.post(name: .hotKeySettingsChanged, object: nil)
        }
    }

    @Published public var shelfShortcut: KeyCombo? {
        didSet {
            if let shelfShortcut = shelfShortcut, let data = try? JSONEncoder().encode(shelfShortcut) {
                defaults.set(data, forKey: Keys.shelfShortcut)
            } else {
                defaults.removeObject(forKey: Keys.shelfShortcut)
            }
            NotificationCenter.default.post(name: .hotKeySettingsChanged, object: nil)
        }
    }

    @Published public var scrollGestureEnabled: Bool {
        didSet { defaults.set(scrollGestureEnabled, forKey: Keys.scrollGestureEnabled) }
    }

    @Published public var emptyClickGestureEnabled: Bool {
        didSet { defaults.set(emptyClickGestureEnabled, forKey: Keys.emptyClickGestureEnabled) }
    }

    @Published public var notchAwarenessEnabled: Bool {
        didSet { defaults.set(notchAwarenessEnabled, forKey: Keys.notchAwarenessEnabled) }
    }

    @Published public var menuBarSpacing: Double {
        didSet { defaults.set(menuBarSpacing, forKey: Keys.menuBarSpacing) }
    }

    @Published public var isProActivated: Bool {
        didSet { defaults.set(isProActivated, forKey: Keys.isProActivated) }
    }

    @Published public var hasSeenWelcome: Bool {
        didSet { defaults.set(hasSeenWelcome, forKey: Keys.hasSeenWelcome) }
    }

    @Published public var customAppZones: [String: Int] {
        didSet {
            defaults.set(customAppZones, forKey: Keys.customAppZones)
            NotificationCenter.default.post(name: .appZonesChanged, object: nil)
        }
    }

    private init() {
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        self.autoCollapseEnabled = defaults.object(forKey: Keys.autoCollapseEnabled) != nil ? defaults.bool(forKey: Keys.autoCollapseEnabled) : true
        self.autoCollapseDelay = defaults.object(forKey: Keys.autoCollapseDelay) != nil ? defaults.double(forKey: Keys.autoCollapseDelay) : 5.0
        self.hideSeparatorWhenCollapsed = defaults.bool(forKey: Keys.hideSeparatorWhenCollapsed)
        self.alwaysHiddenEnabled = defaults.object(forKey: Keys.alwaysHiddenEnabled) != nil ? defaults.bool(forKey: Keys.alwaysHiddenEnabled) : true
        self.hoverToExpand = defaults.bool(forKey: Keys.hoverToExpand)
        self.hoverDwellTime = defaults.object(forKey: Keys.hoverDwellTime) != nil ? defaults.double(forKey: Keys.hoverDwellTime) : 0.4
        self.playSoundOnToggle = defaults.bool(forKey: Keys.playSoundOnToggle)

        if let raw = defaults.string(forKey: Keys.expandSound), let effect = SoundEffect(rawValue: raw) {
            self.expandSound = effect
        } else {
            self.expandSound = .pop
        }

        if let raw = defaults.string(forKey: Keys.collapseSound), let effect = SoundEffect(rawValue: raw) {
            self.collapseSound = effect
        } else {
            self.collapseSound = .tink
        }

        self.showHUDNotifications = defaults.object(forKey: Keys.showHUDNotifications) != nil ? defaults.bool(forKey: Keys.showHUDNotifications) : true

        if let raw = defaults.string(forKey: Keys.iconStyle), let style = IconStyle(rawValue: raw) {
            self.iconStyle = style
        } else {
            self.iconStyle = .chevron
        }

        if let raw = defaults.string(forKey: Keys.separatorStyle), let style = SeparatorStyle(rawValue: raw) {
            self.separatorStyle = style
        } else {
            self.separatorStyle = .dot
        }

        if let data = defaults.data(forKey: Keys.toggleShortcut),
           let combo = try? JSONDecoder().decode(KeyCombo.self, from: data) {
            self.toggleShortcut = combo
        } else {
            self.toggleShortcut = KeyCombo.defaultToggle
        }

        if let data = defaults.data(forKey: Keys.alwaysHiddenShortcut),
           let combo = try? JSONDecoder().decode(KeyCombo.self, from: data) {
            self.alwaysHiddenShortcut = combo
        } else {
            self.alwaysHiddenShortcut = KeyCombo.defaultAlwaysHidden
        }

        if let data = defaults.data(forKey: Keys.searchShortcut),
           let combo = try? JSONDecoder().decode(KeyCombo.self, from: data) {
            self.searchShortcut = combo
        } else {
            self.searchShortcut = KeyCombo.defaultSearch
        }

        if let data = defaults.data(forKey: Keys.shelfShortcut),
           let combo = try? JSONDecoder().decode(KeyCombo.self, from: data) {
            self.shelfShortcut = combo
        } else {
            self.shelfShortcut = KeyCombo.defaultShelf
        }

        self.scrollGestureEnabled = defaults.object(forKey: Keys.scrollGestureEnabled) != nil ? defaults.bool(forKey: Keys.scrollGestureEnabled) : true
        self.emptyClickGestureEnabled = defaults.bool(forKey: Keys.emptyClickGestureEnabled)
        self.notchAwarenessEnabled = defaults.object(forKey: Keys.notchAwarenessEnabled) != nil ? defaults.bool(forKey: Keys.notchAwarenessEnabled) : true
        self.menuBarSpacing = defaults.double(forKey: Keys.menuBarSpacing)

        self.isProActivated = true // Unlocked by default in Saklamac Pro
        self.hasSeenWelcome = defaults.bool(forKey: Keys.hasSeenWelcome)
        self.customAppZones = defaults.dictionary(forKey: Keys.customAppZones) as? [String: Int] ?? [:]
    }

    public func setCustomZone(for bundleId: String, section: MenuBarSection?) {
        if let s = section {
            customAppZones[bundleId] = s.rawValue
        } else {
            customAppZones.removeValue(forKey: bundleId)
        }
    }

    public func getCustomZone(for bundleId: String) -> MenuBarSection? {
        if let raw = customAppZones[bundleId], let sec = MenuBarSection(rawValue: raw) {
            return sec
        }
        return nil
    }

    public func resetToDefaults() {
        launchAtLogin = false
        autoCollapseEnabled = true
        autoCollapseDelay = 5.0
        hideSeparatorWhenCollapsed = false
        alwaysHiddenEnabled = true
        hoverToExpand = false
        hoverDwellTime = 0.4
        playSoundOnToggle = false
        expandSound = .pop
        collapseSound = .tink
        showHUDNotifications = true
        iconStyle = .chevron
        separatorStyle = .dot
        toggleShortcut = KeyCombo.defaultToggle
        alwaysHiddenShortcut = KeyCombo.defaultAlwaysHidden
        searchShortcut = KeyCombo.defaultSearch
        shelfShortcut = KeyCombo.defaultShelf
        scrollGestureEnabled = true
        emptyClickGestureEnabled = false
        notchAwarenessEnabled = true
        menuBarSpacing = 0.0
        isProActivated = true
        customAppZones = [:]
    }
}

public extension Notification.Name {
    static let appearanceSettingsChanged = Notification.Name("saklamac.appearanceSettingsChanged")
    static let alwaysHiddenSettingsChanged = Notification.Name("saklamac.alwaysHiddenSettingsChanged")
    static let hotKeySettingsChanged = Notification.Name("saklamac.hotKeySettingsChanged")
    static let hoverSettingsChanged = Notification.Name("saklamac.hoverSettingsChanged")
    static let menuBarStateChanged = Notification.Name("saklamac.menuBarStateChanged")
    static let appZonesChanged = Notification.Name("saklamac.appZonesChanged")
}
