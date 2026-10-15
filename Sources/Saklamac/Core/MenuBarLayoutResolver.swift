import AppKit

public enum MenuBarSection: Int, Comparable {
    case visible = 0
    case hidden = 1
    case alwaysHidden = 2

    public var title: String {
        switch self {
        case .visible: return "Visible"
        case .hidden: return "Drawer"
        case .alwaysHidden: return "Ghost Zone"
        }
    }

    public static func < (lhs: MenuBarSection, rhs: MenuBarSection) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public struct MenuBarLayout: Equatable {
    public var appSections: [String: MenuBarSection]

    public init(appSections: [String: MenuBarSection] = [:]) {
        self.appSections = appSections
    }

    public func bundles(in sections: Set<MenuBarSection>) -> [String] {
        return appSections.filter { sections.contains($0.value) }.map(\.key).sorted()
    }
}

public enum MenuBarLayoutResolver {
    public static let systemBundles: Set<String> = [
        "com.apple.MenuBarAgent",
        "com.apple.controlcenter",
        "com.apple.systemuiserver",
        "com.apple.notificationcenterui"
    ]

    public static func resolve(items: [MenuBarItemInfo],
                               toggleBoundary: CGRect,
                               alwaysHiddenBoundary: CGRect?,
                               isLTR: Bool = true,
                               ownBundleId: String? = Bundle.main.bundleIdentifier) -> MenuBarLayout {
        var sections: [String: MenuBarSection] = [:]

        for item in items {
            let bundle = item.bundleIdentifier
            if bundle == ownBundleId || systemBundles.contains(bundle) {
                continue
            }

            let sec = classify(
                x: item.frame.midX,
                toggleX: toggleBoundary.midX,
                alwaysHiddenX: alwaysHiddenBoundary?.midX,
                isLTR: isLTR
            )

            // Most visible section wins
            if let existing = sections[bundle] {
                sections[bundle] = min(existing, sec)
            } else {
                sections[bundle] = sec
            }
        }

        return MenuBarLayout(appSections: sections)
    }

    private static func classify(x: CGFloat,
                                 toggleX: CGFloat,
                                 alwaysHiddenX: CGFloat?,
                                 isLTR: Bool) -> MenuBarSection {
        // Distance toward arrow/visible side: positive means visible
        let diffFromToggle = isLTR ? (x - toggleX) : (toggleX - x)
        if diffFromToggle > 0 {
            return .visible
        }

        if let ax = alwaysHiddenX {
            let diffFromAlways = isLTR ? (x - ax) : (ax - x)
            if diffFromAlways < 0 {
                return .alwaysHidden
            }
        }

        return .hidden
    }
}
