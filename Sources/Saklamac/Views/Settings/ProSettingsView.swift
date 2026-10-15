import SwiftUI

public struct ProSettingsView: View {
    @ObservedObject var prefs = PreferencesManager.shared
    @StateObject private var preview = PreviewState(isCollapsed: true)

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Pro Badge Card
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color.yellow.opacity(0.85), Color.orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)

                        Image(systemName: "crown.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Saklamac Pro")
                                .font(.system(size: 17, weight: .bold))
                            Text("COMMERCIAL LICENSE UNLOCKED")
                                .font(.system(size: 9, weight: .heavy))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(4)
                        }

                        Text("All premium organization, Ghost Zone, and native WindowServer features are fully unlocked.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.35), lineWidth: 1)
                )

                // Feature: Ghost Zone Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Ghost Zone (Completely Concealed Section)")
                                .font(.system(size: 13, weight: .bold))
                            Text("Adds a second separator in your menu bar for items you want permanently concealed from your regular drawer.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $prefs.alwaysHiddenEnabled)
                            .labelsHidden()
                            .toggleStyle(.switch)
                    }

                    if prefs.alwaysHiddenEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("How the Ghost Zone works:")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.primary)

                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "1.circle.fill")
                                    .foregroundColor(.accentColor)
                                Text("Hold ⌘ (Command) and drag unwanted status icons to the left of the double-dot separator (⫶).")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "2.circle.fill")
                                    .foregroundColor(.accentColor)
                                Text("These icons remain hidden even when you expand your regular hidden icons.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "3.circle.fill")
                                    .foregroundColor(.accentColor)
                                Text("To reveal them temporarily, hold ⌥ (Option) and click the chevron, or press your custom Ghost Zone hotkey (default ⌘⌥J).")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.accentColor.opacity(0.06))
                        )
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(NSColor.controlBackgroundColor))
                )

                // Interactive Demonstration
                VStack(alignment: .leading, spacing: 8) {
                    Text("Interactive Zone Preview")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)

                    SimulatedMenuBarView(
                        isCollapsed: $preview.isCollapsed,
                        showAlwaysHidden: prefs.alwaysHiddenEnabled
                    )
                }

                // Licensing & Attribution
                VStack(alignment: .leading, spacing: 8) {
                    Text("License Information")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tier: Saklamac Pro Lifetime")
                                .font(.system(size: 12, weight: .medium))
                            Text("Licensed by: TheManOfTalent (Mehmet Akif Cifci)")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 20))
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                }
            }
            .padding(20)
        }
    }
}
