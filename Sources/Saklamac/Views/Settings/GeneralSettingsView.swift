import SwiftUI

public struct GeneralSettingsView: View {
    @ObservedObject var prefs = PreferencesManager.shared

    let intervals: [(Double, String)] = [
        (1.0, "1 second"),
        (3.0, "3 seconds"),
        (5.0, "5 seconds (Default)"),
        (10.0, "10 seconds"),
        (15.0, "15 seconds"),
        (30.0, "30 seconds")
    ]

    private var isMacOS27: Bool {
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 27
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Section 1: macOS 27 Architecture
                if isMacOS27 {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("macOS 27 Architecture")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)

                        HStack(spacing: 14) {
                            Image(systemName: AccessibilityInventory.shared.isAuthorized ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                                .foregroundColor(AccessibilityInventory.shared.isAuthorized ? .green : .orange)
                                .font(.system(size: 24))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(AccessibilityInventory.shared.isAuthorized ? "macOS 27 Native Engine: Active" : "Accessibility Permission Required")
                                    .font(.system(size: 13, weight: .semibold))
                                Text(AccessibilityInventory.shared.isAuthorized ? "Saklamac is reading menu bar positions and hiding icons natively." : "To detect icon positions on macOS 27, grant Accessibility permission.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()

                            if !AccessibilityInventory.shared.isAuthorized {
                                Button("Grant Permission") {
                                    AccessibilityInventory.shared.requestAuthorization()
                                    AccessibilityInventory.shared.openSystemSettings()
                                }
                                .controlSize(.regular)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(NSColor.controlBackgroundColor))
                        )
                    }
                }

                // Section 2: System
                VStack(alignment: .leading, spacing: 10) {
                    Text("System")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    VStack(spacing: 12) {
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Start at Login")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Automatically launch Saklamac when you log into your Mac.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $prefs.launchAtLogin)
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

                // Section 3: Behavior
                VStack(alignment: .leading, spacing: 10) {
                    Text("Behavior")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    VStack(spacing: 12) {
                        // Auto-Hide Icons
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Auto-Hide Icons")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Automatically collapse hidden icons again after a period of inactivity.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $prefs.autoCollapseEnabled)
                                .labelsHidden()
                                .toggleStyle(.switch)
                        }

                        if prefs.autoCollapseEnabled {
                            HStack {
                                Text("Auto-Hide Delay:")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Picker("", selection: $prefs.autoCollapseDelay) {
                                    ForEach(intervals, id: \.0) { item in
                                        Text(item.1).tag(item.0)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 170)
                            }
                            .padding(.leading, 8)
                        }

                        Divider()

                        // Hide Separator When Collapsed
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Hide Separator When Collapsed")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Completely hides the separator dot so only the toggle chevron is visible.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $prefs.hideSeparatorWhenCollapsed)
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

                // Section 4: Interaction
                VStack(alignment: .leading, spacing: 10) {
                    Text("Interaction")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    VStack(spacing: 12) {
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Hover to Expand")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Automatically reveal hidden icons when your cursor rests in the menu bar.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $prefs.hoverToExpand)
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
            }
            .padding(20)
        }
    }
}
