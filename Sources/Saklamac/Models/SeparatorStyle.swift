import AppKit

public enum SeparatorStyle: String, CaseIterable, Identifiable, Codable {
    case dot = "dot"
    case line = "line"
    case doubleDot = "doubleDot"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .dot: return "Subtle Dot (•)"
        case .line: return "Vertical Bar (┃)"
        case .doubleDot: return "Double Dot (⫶)"
        }
    }

    public var image: NSImage {
        switch self {
        case .dot:
            let image = NSImage(size: NSSize(width: 14, height: 18))
            image.lockFocus()
            let dotRect = NSRect(x: 4.5, y: 6.5, width: 5, height: 5)
            let path = NSBezierPath(ovalIn: dotRect)
            NSColor.black.setFill()
            path.fill()
            image.unlockFocus()
            image.isTemplate = true
            return image

        case .line:
            let image = NSSize(width: 12, height: 18)
            let img = NSImage(size: image)
            img.lockFocus()
            let rect = NSRect(x: 5, y: 3, width: 2, height: 12)
            let path = NSBezierPath(roundedRect: rect, xRadius: 1, yRadius: 1)
            NSColor.black.setFill()
            path.fill()
            img.unlockFocus()
            img.isTemplate = true
            return img

        case .doubleDot:
            let image = NSImage(size: NSSize(width: 14, height: 18))
            image.lockFocus()
            let dot1 = NSBezierPath(ovalIn: NSRect(x: 5, y: 11, width: 4, height: 4))
            let dot2 = NSBezierPath(ovalIn: NSRect(x: 5, y: 3, width: 4, height: 4))
            NSColor.black.setFill()
            dot1.fill()
            dot2.fill()
            image.unlockFocus()
            image.isTemplate = true
            return image
        }
    }
}
