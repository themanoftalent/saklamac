import AppKit
import SwiftUI

@MainActor
public final class MenuBarController: NSObject {
    public static let shared = MenuBarController()

    // MARK: - Status Items
    public let toggleItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    public let separatorItem = NSStatusBar.system.statusItem(withLength: 16)
    public var alwaysHiddenItem: NSStatusItem?

    public var toggleItemFrame: CGRect? {
        guard let win = toggleItem.button?.window else { return nil }
        return win.frame
    }

    public var alwaysHiddenItemFrame: CGRect? {
        guard let win = alwaysHiddenItem?.button?.window else { return nil }
        return win.frame
    }

    // MARK: - Engine
    private lazy var engine: MenuBarEngine = {
        let osMajor = ProcessInfo.processInfo.operatingSystemVersion.majorVersion
        if osMajor >= 27 && NativeVisibilityBridge.shared.isAvailable {
            NSLog("MenuBarController: Using NativeVisibilityEngine (macOS 27+)")
            return NativeVisibilityEngine(controller: self)
        } else {
            NSLog("MenuBarController: Using LegacyLengthEngine (macOS <= 26)")
            return LegacyLengthEngine(controller: self)
        }
    }()

    // MARK: - State
    public private(set) var currentState: MenuBarState = .expanded
    private var autoCollapseTimer: Timer?
    private var hoverMonitor: Any?
    private var hoverDwellTimer: Timer?

    private let preferences = PreferencesManager.shared
    private let expandedLength: CGFloat = 16

    private var isMouseInMenuBar: Bool {
        let mouse = NSEvent.mouseLocation
        return NSScreen.screens.contains { screen in
            mouse.x >= screen.frame.minX && mouse.x <= screen.frame.maxX
                && mouse.y >= screen.visibleFrame.maxY && mouse.y <= screen.frame.maxY
        }
    }

    override private init() {
        super.init()
        setupStatusItems()
        setupObservers()
        setupHotKeys()
        setupHoverMonitor()
        setupScrollGestureMonitor()

        // Collapse shortly after launch to allow macOS menu bar to settle positions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.collapse()
        }
    }

    // MARK: - Setup
    private func setupStatusItems() {
        // 1. Toggle Item
        toggleItem.autosaveName = "saklamac_toggle"
        if let button = toggleItem.button {
            button.image = preferences.iconStyle.image(forCollapsed: currentState == .collapsed)
            button.target = self
            button.action = #selector(toggleButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.toolTip = "Saklamac: Click to toggle menu bar icons, Right-click for options"
        }

        // 2. Separator Item
        separatorItem.autosaveName = "saklamac_separator"
        updateSeparatorAppearance()
        if let button = separatorItem.button {
            button.target = self
            button.action = #selector(separatorButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.toolTip = "Saklamac Separator: Hold ⌘ (Command) and drag icons to the left of this dot to hide them"
        }

        // 3. Always Hidden Item (Ghost Zone)
        updateAlwaysHiddenItem()
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppearanceChanged),
            name: .appearanceSettingsChanged,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAlwaysHiddenChanged),
            name: .alwaysHiddenSettingsChanged,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHoverChanged),
            name: .hoverSettingsChanged,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScreenChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    private func setupHotKeys() {
        if let toggleCombo = preferences.toggleShortcut {
            HotKeyManager.shared.register(id: HotKeyManager.toggleHotKeyID, combo: toggleCombo) { [weak self] in
                self?.toggle()
            }
        }

        if let alwaysCombo = preferences.alwaysHiddenShortcut {
            HotKeyManager.shared.register(id: HotKeyManager.alwaysHiddenHotKeyID, combo: alwaysCombo) { [weak self] in
                self?.toggleAlwaysHidden()
            }
        }
    }

    private func setupHoverMonitor() {
        if let monitor = hoverMonitor {
            NSEvent.removeMonitor(monitor)
            hoverMonitor = nil
        }

        guard preferences.hoverToExpand else { return }

        hoverMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                guard self.currentState == .collapsed && self.isMouseInMenuBar else {
                    self.hoverDwellTimer?.invalidate()
                    self.hoverDwellTimer = nil
                    return
                }

                guard self.hoverDwellTimer == nil else { return }
                self.hoverDwellTimer = Timer.scheduledTimer(withTimeInterval: self.preferences.hoverDwellTime, repeats: false) { [weak self] _ in
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        self.hoverDwellTimer = nil
                        if self.currentState == .collapsed && self.isMouseInMenuBar {
                            self.expand()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Actions
    @objc private func toggleButtonClicked(sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        let isOption = event.modifierFlags.contains(.option)
        let isRightClick = event.type == .rightMouseUp || event.modifierFlags.contains(.control)

        if isRightClick {
            showContextMenu(from: sender)
        } else if isOption {
            toggleAlwaysHidden()
        } else {
            toggle()
        }
    }

    @objc private func separatorButtonClicked(sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp || event.modifierFlags.contains(.control) {
            showContextMenu(from: sender)
        } else {
            toggle()
        }
    }

    public func toggle() {
        if currentState == .collapsed {
            expand()
        } else {
            collapse()
        }
    }

    public func expand() {
        autoCollapseTimer?.invalidate()
        autoCollapseTimer = nil

        engine.expand { [weak self] _ in
            guard let self = self else { return }
            self.currentState = .expanded
            self.updateIcons()
            SoundManager.shared.playToggleSound(expanded: true)
            NotificationCenter.default.post(name: .menuBarStateChanged, object: nil)
            self.scheduleAutoCollapseIfNeeded()
        }
    }

    public func collapse() {
        autoCollapseTimer?.invalidate()
        autoCollapseTimer = nil

        engine.collapse { [weak self] _ in
            guard let self = self else { return }
            self.currentState = .collapsed
            self.updateIcons()
            SoundManager.shared.playToggleSound(expanded: false)
            NotificationCenter.default.post(name: .menuBarStateChanged, object: nil)
        }
    }

    public func toggleAlwaysHidden() {
        guard preferences.alwaysHiddenEnabled else {
            toggle()
            return
        }

        if currentState == .alwaysHiddenRevealed {
            collapse()
        } else {
            revealAlwaysHidden()
        }
    }

    public func revealAlwaysHidden() {
        autoCollapseTimer?.invalidate()
        autoCollapseTimer = nil

        engine.revealAlwaysHidden { [weak self] _ in
            guard let self = self else { return }
            self.currentState = .alwaysHiddenRevealed
            self.updateIcons()
            SoundManager.shared.playToggleSound(expanded: true)
            NotificationCenter.default.post(name: .menuBarStateChanged, object: nil)
            self.scheduleAutoCollapseIfNeeded()
        }
    }

    // MARK: - Auto Collapse
    private func scheduleAutoCollapseIfNeeded() {
        guard preferences.autoCollapseEnabled else { return }
        autoCollapseTimer?.invalidate()

        autoCollapseTimer = Timer.scheduledTimer(withTimeInterval: preferences.autoCollapseDelay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.checkAndAutoCollapse()
            }
        }
    }

    private func checkAndAutoCollapse() {
        if isMouseInMenuBar {
            autoCollapseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.checkAndAutoCollapse()
                }
            }
            return
        }

        if WindowManager.shared.isAnyWindowVisible {
            autoCollapseTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.checkAndAutoCollapse()
                }
            }
            return
        }

        collapse()
    }

    // MARK: - Appearance Updates
    private func updateIcons() {
        let isCollapsed = currentState == .collapsed
        toggleItem.button?.image = preferences.iconStyle.image(forCollapsed: isCollapsed)
        updateSeparatorAppearance()
    }

    private func updateSeparatorAppearance() {
        if currentState == .collapsed && preferences.hideSeparatorWhenCollapsed {
            separatorItem.button?.image = nil
        } else {
            separatorItem.button?.image = preferences.separatorStyle.image
        }
    }

    private func updateAlwaysHiddenItem() {
        if preferences.alwaysHiddenEnabled {
            if alwaysHiddenItem == nil {
                let item = NSStatusBar.system.statusItem(withLength: expandedLength)
                item.autosaveName = "saklamac_always_hidden"
                if let button = item.button {
                    button.image = SeparatorStyle.doubleDot.image
                    button.target = self
                    button.action = #selector(separatorButtonClicked(sender:))
                    button.sendAction(on: [.leftMouseUp, .rightMouseUp])
                    button.toolTip = "Saklamac Ghost Zone: Drag icons to the left of this separator to completely hide them"
                }
                alwaysHiddenItem = item
            }
        } else {
            if let existing = alwaysHiddenItem {
                NSStatusBar.system.removeStatusItem(existing)
                alwaysHiddenItem = nil
            }
        }
    }

    // MARK: - Notifications
    @objc private func handleAppearanceChanged() {
        updateIcons()
    }

    @objc private func handleAlwaysHiddenChanged() {
        updateAlwaysHiddenItem()
        engine.invalidateLayout()
    }

    @objc private func handleHoverChanged() {
        setupHoverMonitor()
    }

    @objc private func handleScreenChanged() {
        engine.invalidateLayout()
    }

    // MARK: - Gestures
    private var scrollEventMonitor: Any?

    private func setupScrollGestureMonitor() {
        if let existing = scrollEventMonitor {
            NSEvent.removeMonitor(existing)
            scrollEventMonitor = nil
        }

        guard preferences.scrollGestureEnabled else { return }

        scrollEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .scrollWheel) { [weak self] event in
            guard let self = self else { return }
            let mouseLoc = NSEvent.mouseLocation
            guard let screen = NSScreen.screens.first(where: { NSMouseInRect(mouseLoc, $0.frame, false) }) else { return }

            let menuBarRect = NSRect(
                x: screen.frame.origin.x,
                y: screen.visibleFrame.maxY,
                width: screen.frame.width,
                height: screen.frame.height - screen.visibleFrame.maxY
            )

            if NSMouseInRect(mouseLoc, menuBarRect, false) {
                if abs(event.scrollingDeltaX) > 4 || abs(event.scrollingDeltaY) > 4 {
                    Task { @MainActor in
                        if event.scrollingDeltaY > 0 || event.scrollingDeltaX > 0 {
                            if self.currentState == .collapsed {
                                self.expand()
                            }
                        } else if event.scrollingDeltaY < 0 || event.scrollingDeltaX < 0 {
                            if self.currentState != .collapsed {
                                self.collapse()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Context Menu
    public func showContextMenu(from button: NSStatusBarButton) {
        let menu = NSMenu()

        // 1. Status header
        let stateTitle: String
        switch currentState {
        case .collapsed: stateTitle = "Status: Drawer Hidden"
        case .expanded: stateTitle = "Status: Drawer Expanded"
        case .alwaysHiddenRevealed: stateTitle = "Status: Ghost Zone Revealed"
        }
        let stateItem = NSMenuItem(title: stateTitle, action: nil, keyEquivalent: "")
        stateItem.isEnabled = false
        menu.addItem(stateItem)

        menu.addItem(NSMenuItem.separator())

        // 2. Toggle action
        let toggleTitle = currentState == .collapsed ? "Show Hidden Icons" : "Hide Icons"
        let toggleActionItem = NSMenuItem(title: toggleTitle, action: #selector(menuTogglePressed), keyEquivalent: "")
        toggleActionItem.target = self
        if let shortcut = preferences.toggleShortcut {
            toggleActionItem.title = "\(toggleTitle) (\(shortcut.displayString))"
        }
        menu.addItem(toggleActionItem)

        // 3. Toggle Always Hidden action
        if preferences.alwaysHiddenEnabled {
            let alwaysTitle = currentState == .alwaysHiddenRevealed ? "Hide Ghost Zone Icons" : "Show Ghost Zone Icons"
            let alwaysActionItem = NSMenuItem(title: alwaysTitle, action: #selector(menuAlwaysHiddenPressed), keyEquivalent: "")
            alwaysActionItem.target = self
            if let shortcut = preferences.alwaysHiddenShortcut {
                alwaysActionItem.title = "\(alwaysTitle) (\(shortcut.displayString))"
            }
            menu.addItem(alwaysActionItem)
        }

        // 4. Floating Shelf
        let shelfTitle = "Toggle Saklamac Shelf"
        let shelfItem = NSMenuItem(title: shelfTitle, action: #selector(menuShelfPressed), keyEquivalent: "")
        shelfItem.target = self
        if let shortcut = preferences.shelfShortcut {
            shelfItem.title = "\(shelfTitle) (\(shortcut.displayString))"
        }
        menu.addItem(shelfItem)

        // 5. Quick Search
        let searchTitle = "Search Menu Bar Apps..."
        let searchItem = NSMenuItem(title: searchTitle, action: #selector(menuSearchPressed), keyEquivalent: "")
        searchItem.target = self
        if let shortcut = preferences.searchShortcut {
            searchItem.title = "\(searchTitle) (\(shortcut.displayString))"
        }
        menu.addItem(searchItem)

        menu.addItem(NSMenuItem.separator())

        // 6. Profiles Submenu
        let profilesMenu = NSMenu()
        for profile in ProfileManager.shared.profiles {
            let item = NSMenuItem(title: profile.name, action: #selector(menuProfileSelected(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = profile.id
            if profile.id == ProfileManager.shared.activeProfileId {
                item.state = .on
            }
            profilesMenu.addItem(item)
        }
        let profilesSubmenuItem = NSMenuItem(title: "Active Profile", action: nil, keyEquivalent: "")
        profilesSubmenuItem.submenu = profilesMenu
        menu.addItem(profilesSubmenuItem)

        menu.addItem(NSMenuItem.separator())

        // 7. Preferences
        let prefsItem = NSMenuItem(title: "Settings...", action: #selector(menuPreferencesPressed), keyEquivalent: ",")
        prefsItem.target = self
        menu.addItem(prefsItem)

        // 8. Setup Guide
        let guideItem = NSMenuItem(title: "Quick Setup Guide...", action: #selector(menuGuidePressed), keyEquivalent: "")
        guideItem.target = self
        menu.addItem(guideItem)

        menu.addItem(NSMenuItem.separator())

        // 9. Brand & Developer Attribution
        let brandItem = NSMenuItem(title: "⭐️ SoftAI Yazılım | Assoc. Prof. Dr. Mehmet Akif Cifci", action: #selector(menuAboutPressed), keyEquivalent: "")
        brandItem.target = self
        menu.addItem(brandItem)

        let aboutItem = NSMenuItem(title: "About Saklamac...", action: #selector(menuAboutPressed), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem.separator())

        // 10. Quit
        let quitItem = NSMenuItem(title: "Quit Saklamac", action: #selector(menuQuitPressed), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        button.menu = menu
        button.performClick(nil)
        button.menu = nil
    }

    @objc private func menuTogglePressed() { toggle() }
    @objc private func menuAlwaysHiddenPressed() { toggleAlwaysHidden() }
    @objc private func menuShelfPressed() { FloatingShelfController.shared.toggle() }
    @objc private func menuSearchPressed() { QuickSearchController.shared.toggle() }
    @objc private func menuProfileSelected(_ sender: NSMenuItem) {
        if let profileId = sender.representedObject as? String {
            ProfileManager.shared.activeProfileId = profileId
        }
    }
    @objc private func menuPreferencesPressed() { WindowManager.shared.showSettingsWindow() }
    @objc private func menuGuidePressed() { WindowManager.shared.showOnboardingWindow() }
    @objc private func menuAboutPressed() { WindowManager.shared.showAboutWindow() }
    @objc private func menuQuitPressed() { NSApp.terminate(nil) }
}
