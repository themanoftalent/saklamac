import SwiftUI

public struct AppearanceSettingsView: View {
    @ObservedObject var prefs = PreferencesManager.shared
    @StateObject private var preview = PreviewState(isCollapsed: true)

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Interactive Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Live Appearance Preview")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)

                    SimulatedMenuBarView(
                        isCollapsed: $preview.isCollapsed,
                        showAlwaysHidden: prefs.alwaysHiddenEnabled
                    )
                }

                // Icon Style Picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("Toggle Button Style")
                        .font(.system(size: 13, weight: .bold))

                    VStack(spacing: 8) {
                        ForEach(IconStyle.allCases) { style in
                            HStack(spacing: 12) {
                                // Icon Preview
                                HStack(spacing: 8) {
                                    Image(nsImage: style.image(forCollapsed: false))
                                    Image(nsImage: style.image(forCollapsed: true))
                                }
                                .frame(width: 48, height: 26)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(NSColor.controlBackgroundColor))
                                )

                                Text(style.displayName)
                                    .font(.system(size: 12))

                                Spacer()

                                if prefs.iconStyle == style {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(prefs.iconStyle == style ? Color.accentColor.opacity(0.12) : Color(NSColor.controlBackgroundColor))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(prefs.iconStyle == style ? Color.accentColor.opacity(0.4) : Color.clear, lineWidth: 1)
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                prefs.iconStyle = style
                            }
                        }
                    }
                }

                // Separator Style Picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("Separator Boundary Style")
                        .font(.system(size: 13, weight: .bold))

                    HStack(spacing: 10) {
                        ForEach(SeparatorStyle.allCases) { sep in
                            VStack(spacing: 8) {
                                Image(nsImage: sep.image)
                                    .frame(height: 24)

                                Text(sep.displayName)
                                    .font(.system(size: 11))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(prefs.separatorStyle == sep ? Color.accentColor.opacity(0.12) : Color(NSColor.controlBackgroundColor))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(prefs.separatorStyle == sep ? Color.accentColor : Color.clear, lineWidth: 1.5)
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                prefs.separatorStyle = sep
                            }
                        }
                    }
                }

                // Spacing Controls
                VStack(alignment: .leading, spacing: 10) {
                    Text("Status Item Density")
                        .font(.system(size: 13, weight: .bold))

                    VStack(spacing: 12) {
                        HStack {
                            Text("Menu Bar Item Spacing:")
                                .font(.system(size: 12))
                            Spacer()
                            Text(spacingLabel(for: prefs.menuBarSpacing))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }

                        Picker("", selection: $prefs.menuBarSpacing) {
                            Text("Compact (-4pt)").tag(-4.0)
                            Text("Standard (Default)").tag(0.0)
                            Text("Relaxed (+4pt)").tag(4.0)
                        }
                        .pickerStyle(.segmented)
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

    private func spacingLabel(for value: Double) -> String {
        if value < 0 { return "Compact" }
        if value > 0 { return "Relaxed" }
        return "Standard"
    }
}
