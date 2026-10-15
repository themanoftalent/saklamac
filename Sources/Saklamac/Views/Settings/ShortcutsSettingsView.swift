import SwiftUI

public struct ShortcutsSettingsView: View {
    @ObservedObject var prefs = PreferencesManager.shared

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Section 1: Global Hotkeys
                VStack(alignment: .leading, spacing: 10) {
                    Text("Global System Hotkeys")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    VStack(spacing: 12) {
                        // Toggle Hidden Section
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Toggle Drawer")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Global shortcut to show or hide secondary menu bar icons.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            KeyRecorderView(keyCombo: $prefs.toggleShortcut)
                        }

                        Divider()

                        // Toggle Ghost Zone Section
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Toggle Ghost Zone")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Global shortcut to reveal or re-hide permanently hidden icons.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            KeyRecorderView(keyCombo: $prefs.alwaysHiddenShortcut)
                        }

                        Divider()

                        // Quick Search Hotkey
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Quick Search Menu Bar Apps")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Summon a Spotlight-style HUD to search and focus status items.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            KeyRecorderView(keyCombo: $prefs.searchShortcut)
                        }

                        Divider()

                        // Floating Shelf Hotkey
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Toggle Floating Shelf")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Display the secondary dropdown bar directly below the menu bar.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            KeyRecorderView(keyCombo: $prefs.shelfShortcut)
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                }

                // Section 2: Visual Feedback (HUD)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Visual Feedback")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    VStack(spacing: 10) {
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Show On-Screen Floating Bezel (HUD)")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Displays a translucent status bezel on screen when triggered.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Button("Preview HUD") {
                                HUDController.shared.show(message: "Drawer Expanded", systemImage: "chevron.left")
                            }
                            .controlSize(.regular)

                            Toggle("", isOn: $prefs.showHUDNotifications)
                                .labelsHidden()
                                .toggleStyle(.switch)
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                }

                // Section 3: Audio Feedback
                VStack(alignment: .leading, spacing: 10) {
                    Text("Audio Feedback")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    VStack(spacing: 12) {
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Play Tactile Sound Effect")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Plays an audible cue when toggling icons or using shortcuts.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $prefs.playSoundOnToggle)
                                .labelsHidden()
                                .toggleStyle(.switch)
                        }

                        if prefs.playSoundOnToggle {
                            Divider()

                            HStack(alignment: .center) {
                                Text("Expand Sound")
                                    .font(.system(size: 12))
                                Spacer()
                                Picker("", selection: $prefs.expandSound) {
                                    ForEach(SoundEffect.allCases) { sound in
                                        Text(sound.displayName).tag(sound)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 140)

                                Button(action: {
                                    SoundManager.shared.playSound(named: prefs.expandSound.rawValue)
                                }) {
                                    Image(systemName: "speaker.wave.2.fill")
                                }
                                .controlSize(.small)
                            }

                            HStack(alignment: .center) {
                                Text("Collapse Sound")
                                    .font(.system(size: 12))
                                Spacer()
                                Picker("", selection: $prefs.collapseSound) {
                                    ForEach(SoundEffect.allCases) { sound in
                                        Text(sound.displayName).tag(sound)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 140)

                                Button(action: {
                                    SoundManager.shared.playSound(named: prefs.collapseSound.rawValue)
                                }) {
                                    Image(systemName: "speaker.wave.2.fill")
                                }
                                .controlSize(.small)
                            }
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                }

                // Section 4: Tips for Shortcuts
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 13))
                        Text("Tips for Shortcuts:")
                            .font(.system(size: 12, weight: .semibold))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top, spacing: 8) {
                            Text("•").foregroundColor(.secondary)
                            Text("Shortcuts work anywhere across macOS, even when other full-screen apps are focused.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        HStack(alignment: .top, spacing: 8) {
                            Text("•").foregroundColor(.secondary)
                            Text("Click (×) next to any recorded hotkey to clear it completely.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        HStack(alignment: .top, spacing: 8) {
                            Text("•").foregroundColor(.secondary)
                            Text("Default Hotkeys: ⌘⌥H (Drawer), ⌘⌥J (Ghost Zone), ⌘⌥Space (Quick Search), ⌘⌥S (Shelf).")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
            }
            .padding(20)
        }
    }
}
