import AppKit

public enum IconStyle: String, CaseIterable, Identifiable, Codable {
    case chevron = "chevron"
    case classicAngle = "classicAngle"
    case arrow = "arrow"
    case dots = "dots"
    case minimalBar = "minimalBar"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .chevron: return "Modern Chevron (‹ / ›)"
        case .classicAngle: return "Classic Angle (< / >)"
        case .arrow: return "Subtle Arrow (← / →)"
        case .dots: return "Minimal Dots (● / ○)"
        case .minimalBar: return "Sleek Bar (┃)"
        }
    }

    public func image(forCollapsed collapsed: Bool) -> NSImage {
        switch self {
        case .chevron:
            let name = collapsed ? "chevron.right" : "chevron.left"
            let config = NSImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            let img = NSImage(systemSymbolName: name, accessibilityDescription: collapsed ? "Expand" : "Collapse")?.withSymbolConfiguration(config)
            img?.isTemplate = true
            return img ?? NSImage()

        case .classicAngle:
            // Custom drawn crisp angle character
            let text = collapsed ? ">" : "<"
            return drawTextImage(text, fontSize: 13, bold: true)

        case .arrow:
            let name = collapsed ? "arrow.right" : "arrow.left"
            let config = NSImage.SymbolConfiguration(pointSize: 11, weight: .medium)
            let img = NSImage(systemSymbolName: name, accessibilityDescription: collapsed ? "Expand" : "Collapse")?.withSymbolConfiguration(config)
            img?.isTemplate = true
            return img ?? NSImage()

        case .dots:
            let name = collapsed ? "circle.fill" : "circle"
            let config = NSImage.SymbolConfiguration(pointSize: 9, weight: .bold)
            let img = NSImage(systemSymbolName: name, accessibilityDescription: collapsed ? "Expand" : "Collapse")?.withSymbolConfiguration(config)
            img?.isTemplate = true
            return img ?? NSImage()

        case .minimalBar:
            return drawVerticalBar(width: 2, height: 12)
        }
    }

    private func drawTextImage(_ text: String, fontSize: CGFloat, bold: Bool) -> NSImage {
        let font = bold ? NSFont.boldSystemFont(ofSize: fontSize) : NSFont.systemFont(ofSize: fontSize)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.black
        ]
        let str = NSAttributedString(string: text, attributes: attrs)
        let size = str.size()
        let width = max(14, ceil(size.width) + 2)
        let height: CGFloat = 16

        let image = NSImage(size: NSSize(width: width, height: height))
        image.lockFocus()
        let point = NSPoint(x: (width - size.width) / 2, y: (height - size.height) / 2)
        str.draw(at: point)
        image.unlockFocus()
        image.isTemplate = true
        return image
    }

    private func drawVerticalBar(width: CGFloat, height: CGFloat) -> NSImage {
        let imgWidth: CGFloat = 12
        let imgHeight: CGFloat = 18
        let image = NSImage(size: NSSize(width: imgWidth, height: imgHeight))
        image.lockFocus()
        let rect = NSRect(x: (imgWidth - width) / 2, y: (imgHeight - height) / 2, width: width, height: height)
        let path = NSBezierPath(roundedRect: rect, xRadius: width / 2, yRadius: width / 2)
        NSColor.black.setFill()
        path.fill()
        image.unlockFocus()
        image.isTemplate = true
        return image
    }
}
