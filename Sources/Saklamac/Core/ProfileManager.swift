import Foundation
import Combine

@MainActor
public final class ProfileManager: ObservableObject {
    public static let shared = ProfileManager()

    private let defaults = UserDefaults.standard
    private let profilesKey = "saklamac_saved_profiles"
    private let activeProfileIdKey = "saklamac_active_profile_id"

    @Published public private(set) var profiles: [AppProfile] = []
    @Published public var activeProfileId: String {
        didSet {
            defaults.set(activeProfileId, forKey: activeProfileIdKey)
            if let active = profiles.first(where: { $0.id == activeProfileId }) {
                apply(profile: active)
            }
        }
    }

    private init() {
        self.activeProfileId = defaults.string(forKey: activeProfileIdKey) ?? "preset_default"
        loadProfiles()
    }

    private func loadProfiles() {
        if let data = defaults.data(forKey: profilesKey),
           let saved = try? JSONDecoder().decode([AppProfile].self, from: data),
           !saved.isEmpty {
            self.profiles = saved
        } else {
            self.profiles = AppProfile.builtInProfiles
            saveProfiles()
        }

        if !profiles.contains(where: { $0.id == activeProfileId }) {
            activeProfileId = profiles.first?.id ?? "preset_default"
        }
    }

    private func saveProfiles() {
        if let encoded = try? JSONEncoder().encode(profiles) {
            defaults.set(encoded, forKey: profilesKey)
        }
    }

    public func apply(profile: AppProfile) {
        let prefs = PreferencesManager.shared
        prefs.autoCollapseDelay = profile.autoCollapseDelay
        prefs.hideSeparatorWhenCollapsed = profile.hideSeparatorWhenCollapsed
        prefs.alwaysHiddenEnabled = profile.alwaysHiddenEnabled
        prefs.hoverToExpand = profile.hoverToExpand
        if !profile.customAppZones.isEmpty {
            prefs.customAppZones = profile.customAppZones
        }
        MenuBarController.shared.expand()
    }

    public func createProfile(name: String, icon: String = "folder.fill", description: String = "") {
        let prefs = PreferencesManager.shared
        let newProfile = AppProfile(
            name: name,
            icon: icon,
            description: description,
            autoCollapseDelay: prefs.autoCollapseDelay,
            hideSeparatorWhenCollapsed: prefs.hideSeparatorWhenCollapsed,
            alwaysHiddenEnabled: prefs.alwaysHiddenEnabled,
            hoverToExpand: prefs.hoverToExpand,
            customAppZones: prefs.customAppZones,
            isBuiltIn: false
        )
        profiles.append(newProfile)
        saveProfiles()
        activeProfileId = newProfile.id
    }

    public func duplicate(profile: AppProfile) {
        var copy = profile
        copy.id = UUID().uuidString
        copy.name = "\(profile.name) Copy"
        copy.isBuiltIn = false
        profiles.append(copy)
        saveProfiles()
        activeProfileId = copy.id
    }

    public func delete(id: String) {
        guard let index = profiles.firstIndex(where: { $0.id == id }) else { return }
        guard !profiles[index].isBuiltIn else { return } // Cannot delete built-in

        profiles.remove(at: index)
        saveProfiles()

        if activeProfileId == id {
            activeProfileId = profiles.first?.id ?? "preset_default"
        }
    }

    public func exportConfigurationJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(profiles) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public func importConfigurationJSON(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8),
              let imported = try? JSONDecoder().decode([AppProfile].self, from: data),
              !imported.isEmpty else {
            return false
        }
        self.profiles = imported
        saveProfiles()
        if let first = imported.first {
            activeProfileId = first.id
        }
        return true
    }
}
