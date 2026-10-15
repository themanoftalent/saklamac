import AppKit

@MainActor
public final class LegacyLengthEngine: MenuBarEngine {
    private weak var controller: MenuBarController?

    public private(set) var state: MenuBarEngineState = .expanded

    private let expandedLength: CGFloat = 16
    private var collapsedLength: CGFloat {
        let maxScreenWidth = NSScreen.screens.map { $0.frame.width }.max() ?? 1728
        return max(500, min(maxScreenWidth * 2, 10_000))
    }

    public init(controller: MenuBarController) {
        self.controller = controller
    }

    public func collapse(completion: @escaping @MainActor (Bool) -> Void) {
        state = .collapsed
        controller?.separatorItem.length = collapsedLength
        if PreferencesManager.shared.alwaysHiddenEnabled {
            controller?.alwaysHiddenItem?.length = collapsedLength
        }
        completion(true)
    }

    public func expand(completion: @escaping @MainActor (Bool) -> Void) {
        state = .expanded
        controller?.separatorItem.length = expandedLength
        if PreferencesManager.shared.alwaysHiddenEnabled {
            controller?.alwaysHiddenItem?.length = collapsedLength
        }
        completion(true)
    }

    public func revealAlwaysHidden(completion: @escaping @MainActor (Bool) -> Void) {
        state = .alwaysHiddenRevealed
        controller?.separatorItem.length = expandedLength
        controller?.alwaysHiddenItem?.length = expandedLength
        completion(true)
    }

    public func invalidateLayout() {
        if state == .collapsed {
            controller?.separatorItem.length = collapsedLength
            controller?.alwaysHiddenItem?.length = collapsedLength
        }
    }
}
