import AppKit

@MainActor
public final class NativeVisibilityEngine: MenuBarEngine {
    private weak var controller: MenuBarController?
    private let bridge = NativeVisibilityBridge.shared
    private let inventory = AccessibilityInventory.shared

    public private(set) var state: MenuBarEngineState = .expanded

    private var activeAssertion: NativeVisibilityAssertion?
    private var cachedLayout: MenuBarLayout?

    // Apple system items to keep visible at all times
    private static let systemItems = Array(0..<64)

    public init(controller: MenuBarController) {
        self.controller = controller
    }

    public func collapse(completion: @escaping @MainActor (Bool) -> Void) {
        state = .calibrating

        withLayout { [weak self] layout in
            guard let self = self else { return }

            let ownId = Bundle.main.bundleIdentifier ?? "com.saklamac.app"
            var allowedBundles = [ownId]

            if let layout = layout {
                let visibleApps = layout.bundles(in: [.visible])
                allowedBundles.append(contentsOf: visibleApps)
                NSLog("NativeVisibilityEngine: Collapsing. Allowed visible apps: \(visibleApps)")
            } else {
                NSLog("NativeVisibilityEngine: Collapsing without accessibility layout.")
            }

            self.bridge.activate(
                allowedSystemItems: Self.systemItems,
                allowedBundleIdentifiers: allowedBundles
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let newAssertion):
                    let old = self.activeAssertion
                    self.activeAssertion = newAssertion
                    old?.invalidate()
                    self.state = .collapsed
                    completion(true)
                case .failure(let error):
                    NSLog("NativeVisibilityEngine: Activation error: \(error.localizedDescription)")
                    self.activeAssertion?.invalidate()
                    self.activeAssertion = nil
                    self.state = .expanded
                    completion(false)
                }
            }
        }
    }

    public func expand(completion: @escaping @MainActor (Bool) -> Void) {
        let alwaysHiddenOn = PreferencesManager.shared.alwaysHiddenEnabled

        if alwaysHiddenOn, let layout = cachedLayout {
            // Keep always-hidden concealed
            let ownId = Bundle.main.bundleIdentifier ?? "com.saklamac.app"
            var allowed = [ownId]
            allowed.append(contentsOf: layout.bundles(in: [.visible, .hidden]))

            bridge.activate(
                allowedSystemItems: Self.systemItems,
                allowedBundleIdentifiers: allowed
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let newAssertion):
                    let old = self.activeAssertion
                    self.activeAssertion = newAssertion
                    old?.invalidate()
                    self.state = .expanded
                    completion(true)
                case .failure:
                    self.releaseAssertion()
                    self.state = .expanded
                    completion(true)
                }
            }
        } else {
            releaseAssertion()
            state = .expanded
            completion(true)
        }
    }

    public func revealAlwaysHidden(completion: @escaping @MainActor (Bool) -> Void) {
        releaseAssertion()
        state = .alwaysHiddenRevealed
        completion(true)
    }

    public func invalidateLayout() {
        if activeAssertion == nil {
            cachedLayout = nil
        }
    }

    private func releaseAssertion() {
        activeAssertion?.invalidate()
        activeAssertion = nil
    }

    private func withLayout(completion: @escaping @MainActor (MenuBarLayout?) -> Void) {
        if activeAssertion != nil, let cached = cachedLayout {
            completion(cached)
            return
        }

        guard let controller = controller,
              let toggleFrame = controller.toggleItemFrame else {
            completion(nil)
            return
        }

        let alwaysHiddenFrame = PreferencesManager.shared.alwaysHiddenEnabled ? controller.alwaysHiddenItemFrame : nil

        if inventory.isAuthorized {
            inventory.snapshot { [weak self] items in
                var layout = MenuBarLayoutResolver.resolve(
                    items: items,
                    toggleBoundary: toggleFrame,
                    alwaysHiddenBoundary: alwaysHiddenFrame,
                    isLTR: true,
                    ownBundleId: Bundle.main.bundleIdentifier
                )
                // Apply manual user overrides from Preferences
                for (bundle, zoneRaw) in PreferencesManager.shared.customAppZones {
                    if let sec = MenuBarSection(rawValue: zoneRaw) {
                        layout.appSections[bundle] = sec
                    }
                }
                self?.cachedLayout = layout
                completion(layout)
            }
        } else {
            inventory.requestAuthorization()
            var layout = MenuBarLayout()
            for (bundle, zoneRaw) in PreferencesManager.shared.customAppZones {
                if let sec = MenuBarSection(rawValue: zoneRaw) {
                    layout.appSections[bundle] = sec
                }
            }
            self.cachedLayout = layout
            completion(layout)
        }
    }
}
