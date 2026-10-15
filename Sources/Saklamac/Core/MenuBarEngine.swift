import AppKit

public enum MenuBarEngineState: Sendable {
    case collapsed
    case expanded
    case alwaysHiddenRevealed
    case calibrating
}

@MainActor
public protocol MenuBarEngine: AnyObject {
    var state: MenuBarEngineState { get }
    func collapse(completion: @escaping @MainActor (Bool) -> Void)
    func expand(completion: @escaping @MainActor (Bool) -> Void)
    func revealAlwaysHidden(completion: @escaping @MainActor (Bool) -> Void)
    func invalidateLayout()
}
