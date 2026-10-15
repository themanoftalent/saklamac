import Foundation
import Combine

public final class PreviewState: ObservableObject {
    @Published public var isCollapsed: Bool

    public init(isCollapsed: Bool = true) {
        self.isCollapsed = isCollapsed
    }

    public func toggle() {
        isCollapsed.toggle()
    }
}
