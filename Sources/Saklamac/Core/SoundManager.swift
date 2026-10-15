import AppKit

public enum SoundEffect: String, CaseIterable, Identifiable, Codable {
    case pop = "Pop"
    case tink = "Tink"
    case bottle = "Bottle"
    case funk = "Funk"
    case purr = "Purr"
    case submarine = "Submarine"

    public var id: String { rawValue }
    public var displayName: String { rawValue }
}

@MainActor
public final class SoundManager {
    public static let shared = SoundManager()

    private init() {}

    public func playToggleSound(expanded: Bool) {
        guard PreferencesManager.shared.playSoundOnToggle else { return }
        let soundName = expanded ? PreferencesManager.shared.expandSound.rawValue : PreferencesManager.shared.collapseSound.rawValue
        playSound(named: soundName)
    }

    public func playSound(named name: String) {
        if let sound = NSSound(named: name) {
            sound.volume = 0.5
            sound.play()
        }
    }
}
