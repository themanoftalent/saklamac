import SwiftUI

public struct FloatingShelfSettingsView: View {
    @ObservedObject var prefs = PreferencesManager.shared
    @ObservedObject var notchDetector = NotchDetector.shared

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Shelf Overview Card
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.8), Color.indigo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)

                        Image(systemName: "menubar.arrow.down.rectangle")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Saklamac Floating Shelf")
                            .font(.system(size: 16, weight: .bold))
                        Text("An elegant secondary dropdown bar below the menu bar to house overflow items, especially on MacBooks with camera notches.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: {
                        FloatingShelfController.shared.toggle()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "eye.fill")
                            Text("Preview Shelf")
                        }
                    }
                    .controlSize(.regular)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                )

                // Notch Protection Intelligence
                VStack(alignment: .leading, spacing: 10) {
                    Text("Display Notch Protection")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    VStack(spacing: 12) {
                        HStack(spacing: 14) {
                            Image(systemName: "camera.badge.ellipsis")
                                .font(.system(size: 22))
                                .foregroundColor(notchDetector.currentNotchInfo.hasNotch ? .orange : .secondary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Camera Notch Adaptation")
                                    .font(.system(size: 13, weight: .medium))
                                Text(notchDetector.currentNotchInfo.hasNotch
                                     ? "Active: Your display has a hardware camera notch. The shelf ensures icons never get swallowed behind it."
                                     : "Inactive: Your display has a continuous rectangular top bar.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $prefs.notchAwarenessEnabled)
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

                // Hotkey & Triggering
                VStack(alignment: .leading, spacing: 10) {
                    Text("Shelf Hotkey")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    VStack(spacing: 12) {
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Toggle Floating Shelf Shortcut")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Global hotkey to summon or dismiss the shelf anywhere.")
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

                // Shelf Styling & Experience
                VStack(alignment: .leading, spacing: 10) {
                    Text("Shelf Styling")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    VStack(spacing: 10) {
                        HStack {
                            Text("Material Theme")
                                .font(.system(size: 12))
                            Spacer()
                            Text("Frosted Glass (Ultra-Thin)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }

                        Divider()

                        HStack {
                            Text("Corner Radius")
                                .font(.system(size: 12))
                            Spacer()
                            Text("16 pt Smooth Pill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }

                        Divider()

                        HStack {
                            Text("Interactive App Click")
                                .font(.system(size: 12))
                            Spacer()
                            Text("Focus & Bring to Foreground")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                }
            }
            .padding(20)
        }
    }
}
