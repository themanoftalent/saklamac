import AppKit

public struct NotchInfo: Equatable, Sendable {
    public let hasNotch: Bool
    public let screenWidth: CGFloat
    public let screenHeight: CGFloat
    public let menuBarHeight: CGFloat
    public let notchWidth: CGFloat
    public let notchHeight: CGFloat
    public let leftAreaWidth: CGFloat
    public let rightAreaWidth: CGFloat
    public let displayDescription: String

    public static let standard = NotchInfo(
        hasNotch: false,
        screenWidth: 1920,
        screenHeight: 1080,
        menuBarHeight: 24,
        notchWidth: 0,
        notchHeight: 0,
        leftAreaWidth: 960,
        rightAreaWidth: 960,
        displayDescription: "Standard Display"
    )
}

@MainActor
public final class NotchDetector: ObservableObject {
    public static let shared = NotchDetector()

    @Published public private(set) var currentNotchInfo: NotchInfo = .standard

    private init() {
        updateInfo()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    @objc private func screenParametersChanged() {
        updateInfo()
    }

    public func updateInfo() {
        guard let screen = NSScreen.main else {
            currentNotchInfo = .standard
            return
        }

        let frame = screen.frame
        let visibleFrame = screen.visibleFrame
        let menuBarHeight = frame.height - visibleFrame.origin.y - visibleFrame.height

        let topInset = screen.safeAreaInsets.top
        let hasNotch = topInset > 0

        var notchW: CGFloat = 0
        var notchH: CGFloat = 0
        var leftW: CGFloat = frame.width / 2
        var rightW: CGFloat = frame.width / 2

        if hasNotch {
            notchH = topInset
            if let leftArea = screen.auxiliaryTopLeftArea,
               let rightArea = screen.auxiliaryTopRightArea {
                leftW = leftArea.width
                rightW = rightArea.width
                notchW = frame.width - (leftW + rightW)
            } else {
                notchW = 210 // Approximate standard Apple notch width
                leftW = (frame.width - notchW) / 2
                rightW = leftW
            }
        }

        let name = screen.localizedName
        let desc = hasNotch ? "\(name) (Liquid Retina with Notch)" : "\(name) (Standard)"

        currentNotchInfo = NotchInfo(
            hasNotch: hasNotch,
            screenWidth: frame.width,
            screenHeight: frame.height,
            menuBarHeight: menuBarHeight > 0 ? menuBarHeight : (hasNotch ? 38 : 24),
            notchWidth: notchW,
            notchHeight: notchH,
            leftAreaWidth: leftW,
            rightAreaWidth: rightW,
            displayDescription: desc
        )
    }
}
