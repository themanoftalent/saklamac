import Foundation

public struct AppProfile: Identifiable, Codable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var icon: String
    public var description: String
    public var autoCollapseDelay: Double
    public var hideSeparatorWhenCollapsed: Bool
    public var alwaysHiddenEnabled: Bool
    public var hoverToExpand: Bool
    public var customAppZones: [String: Int] // BundleID -> MenuBarSection rawValue
    public var isBuiltIn: Bool

    public init(
        id: String = UUID().uuidString,
        name: String,
        icon: String,
        description: String,
        autoCollapseDelay: Double = 5.0,
        hideSeparatorWhenCollapsed: Bool = true,
        alwaysHiddenEnabled: Bool = true,
        hoverToExpand: Bool = false,
        customAppZones: [String: Int] = [:],
        isBuiltIn: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.description = description
        self.autoCollapseDelay = autoCollapseDelay
        self.hideSeparatorWhenCollapsed = hideSeparatorWhenCollapsed
        self.alwaysHiddenEnabled = alwaysHiddenEnabled
        self.hoverToExpand = hoverToExpand
        self.customAppZones = customAppZones
        self.isBuiltIn = isBuiltIn
    }

    public static let builtInProfiles: [AppProfile] = [
        AppProfile(
            id: "preset_default",
            name: "Default (Balanced)",
            icon: "sparkles",
            description: "Balanced configuration for everyday desktop usage.",
            autoCollapseDelay: 5.0,
            hideSeparatorWhenCollapsed: false,
            alwaysHiddenEnabled: true,
            hoverToExpand: false,
            customAppZones: [:],
            isBuiltIn: true
        ),
        AppProfile(
            id: "preset_minimal",
            name: "Zen Minimalist",
            icon: "leaf.fill",
            description: "Conceals virtually all utility icons for distraction-free focus.",
            autoCollapseDelay: 2.0,
            hideSeparatorWhenCollapsed: true,
            alwaysHiddenEnabled: true,
            hoverToExpand: true,
            customAppZones: [:],
            isBuiltIn: true
        ),
        AppProfile(
            id: "preset_work",
            name: "Work & Productivity",
            icon: "briefcase.fill",
            description: "Keeps communication, calendar, and task utilities immediately accessible.",
            autoCollapseDelay: 10.0,
            hideSeparatorWhenCollapsed: false,
            alwaysHiddenEnabled: true,
            hoverToExpand: true,
            customAppZones: [:],
            isBuiltIn: true
        ),
        AppProfile(
            id: "preset_presentation",
            name: "Presentation / Screen Share",
            icon: "person.crop.rectangle.fill",
            description: "Hides personal messengers, email clients, and background sync badges.",
            autoCollapseDelay: 1.0,
            hideSeparatorWhenCollapsed: true,
            alwaysHiddenEnabled: true,
            hoverToExpand: false,
            customAppZones: [:],
            isBuiltIn: true
        )
    ]
}
