import Foundation
import Carbon
import AppKit

@MainActor
public final class HotKeyManager {
    public static let shared = HotKeyManager()

    private var eventHandlerRef: EventHandlerRef?
    private var registeredHotKeys: [UInt32: EventHotKeyRef] = [:]
    private var actionHandlers: [UInt32: () -> Void] = [:]

    public static let toggleHotKeyID: UInt32 = 1
    public static let alwaysHiddenHotKeyID: UInt32 = 2
    public static let searchHotKeyID: UInt32 = 3
    public static let shelfHotKeyID: UInt32 = 4

    private let signature: OSType = 0x53414B4C // 'SAKL'

    private init() {
        installCarbonHandler()
        setupListeners()
    }

    private func setupListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHotKeySettingsChanged),
            name: .hotKeySettingsChanged,
            object: nil
        )
        registerAllConfiguredHotKeys()
    }

    private func installCarbonHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (callRef, eventRef, userData) -> OSStatus in
                guard let event = eventRef else { return noErr }
                var hotKeyID = EventHotKeyID()
                let err = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                if err == noErr {
                    let id = hotKeyID.id
                    Task { @MainActor in
                        HotKeyManager.shared.handleHotKeyTrigger(id: id)
                    }
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )

        if status != noErr {
            NSLog("HotKeyManager: Failed to install Carbon event handler: \(status)")
        }
    }

    public func registerAllConfiguredHotKeys() {
        unregisterAll()

        let prefs = PreferencesManager.shared
        if let toggle = prefs.toggleShortcut {
            register(id: Self.toggleHotKeyID, combo: toggle) {
                MenuBarController.shared.toggle()
                if prefs.showHUDNotifications {
                    let isCollapsed = MenuBarController.shared.currentState == .collapsed
                    HUDController.shared.show(
                        message: isCollapsed ? "Drawer Hidden" : "Drawer Expanded",
                        systemImage: isCollapsed ? "chevron.right" : "chevron.left"
                    )
                }
            }
        }

        if prefs.alwaysHiddenEnabled, let always = prefs.alwaysHiddenShortcut {
            register(id: Self.alwaysHiddenHotKeyID, combo: always) {
                MenuBarController.shared.toggleAlwaysHidden()
                if prefs.showHUDNotifications {
                    HUDController.shared.show(
                        message: "Ghost Zone Toggled",
                        systemImage: "lock.shield.fill"
                    )
                }
            }
        }

        if let search = prefs.searchShortcut {
            register(id: Self.searchHotKeyID, combo: search) {
                QuickSearchController.shared.toggle()
            }
        }

        if let shelf = prefs.shelfShortcut {
            register(id: Self.shelfHotKeyID, combo: shelf) {
                FloatingShelfController.shared.toggle()
            }
        }
    }

    public func register(id: UInt32, combo: KeyCombo, action: @escaping () -> Void) {
        unregister(id: id)

        actionHandlers[id] = action

        var hotKeyRef: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: signature, id: id)

        let status = RegisterEventHotKey(
            combo.keyCode,
            combo.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status == noErr, let ref = hotKeyRef {
            registeredHotKeys[id] = ref
            NSLog("HotKeyManager: Successfully registered hotkey ID \(id) [\(combo.displayString)]")
        } else {
            NSLog("HotKeyManager: Failed to register hotkey ID \(id): \(status)")
        }
    }

    public func unregister(id: UInt32) {
        if let ref = registeredHotKeys[id] {
            UnregisterEventHotKey(ref)
            registeredHotKeys.removeValue(forKey: id)
            actionHandlers.removeValue(forKey: id)
        }
    }

    public func unregisterAll() {
        for (_, ref) in registeredHotKeys {
            UnregisterEventHotKey(ref)
        }
        registeredHotKeys.removeAll()
        actionHandlers.removeAll()
    }

    public func handleHotKeyTrigger(id: UInt32) {
        if let handler = actionHandlers[id] {
            handler()
        }
    }

    @objc private func handleHotKeySettingsChanged() {
        registerAllConfiguredHotKeys()
    }
}
