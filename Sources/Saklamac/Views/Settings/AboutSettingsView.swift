import SwiftUI
import AppKit

public struct AboutSettingsView: View {
    @ObservedObject var prefs = PreferencesManager.shared

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // App Logo & Pro Badge
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.12, green: 0.16, blue: 0.28),
                                        Color(red: 0.05, green: 0.08, blue: 0.16)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )

                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.orange)
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 8, height: 8)
                        }
                    }

                    Text("Saklamac Pro")
                        .font(.system(size: 22, weight: .bold))

                    HStack(spacing: 8) {
                        Text("Version 1.0.0 (Build 2026.1)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        Text("PRO UNLOCKED")
                            .font(.system(size: 9, weight: .heavy))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }

                    Text("The High-Performance, Privacy-First Menu Bar Manager for macOS")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }

                // MARK: - Card 1: Open Source | Free to Fork & Use
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color(red: 0.06, green: 0.48, blue: 0.98))
                                .frame(width: 24, height: 24)
                            Text("{}")
                                .font(.system(size: 12, weight: .heavy, design: .monospaced))
                                .foregroundColor(.white)
                        }

                        Text("Open Source | Free to Fork & Use")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)

                        Spacer()
                    }

                    Text("Feel free to fork, modify, use, and contribute!")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 7) {
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text("Developed by:")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .frame(width: 105, alignment: .leading)
                            Text(prefs.companyName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                            Spacer()
                        }

                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text("Developer:")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .frame(width: 105, alignment: .leading)
                            Text(prefs.developerTitle)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                            Spacer()
                        }

                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text("GitHub:")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .frame(width: 105, alignment: .leading)
                            Button(action: {
                                if let url = URL(string: prefs.portfolioURL) {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Text(prefs.githubUsername)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(red: 0.06, green: 0.48, blue: 0.98))
                            }
                            .buttonStyle(.plain)
                            .onHover { isHovered in
                                if isHovered { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                            }
                            Spacer()
                        }
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(NSColor.separatorColor).opacity(0.55), lineWidth: 1)
                )

                // MARK: - Card 2: Follow & Support
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Text("❤️")
                            .font(.system(size: 15))

                        Text("Follow & Support")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)

                        Spacer()
                    }

                    Text("If you find this project useful, star the repository, follow me, or buy me a coffee! Your support helps keep future projects free and open-source.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 12) {
                        // GitHub Button
                        Button(action: {
                            if let url = URL(string: prefs.githubURL) {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text("</>")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color(red: 0.06, green: 0.48, blue: 0.98))
                                Text("GitHub")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.blue.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.blue.opacity(0.35), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .onHover { isHovered in
                            if isHovered { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                        }

                        // Sponsor Me Button
                        Button(action: {
                            if let url = URL(string: prefs.sponsorURL) {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text("❤️")
                                    .font(.system(size: 12))
                                Text("Sponsor Me")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.pink.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.pink.opacity(0.35), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .onHover { isHovered in
                            if isHovered { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                        }

                        // Buy Me a Coffee Button
                        Button(action: {
                            if let url = URL(string: prefs.buyMeACoffeeURL) {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text("☕")
                                    .font(.system(size: 13))
                                Text("Buy Me a Coffee")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.orange.opacity(0.09))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.orange.opacity(0.38), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .onHover { isHovered in
                            if isHovered { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                        }

                        Spacer()
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(NSColor.separatorColor).opacity(0.55), lineWidth: 1)
                )

                // Quick Setup Guide
                Button(action: {
                    WindowManager.shared.showOnboardingWindow()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "questionmark.circle.fill")
                        Text("Show Interactive Setup Guide")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .onHover { isHovered in
                    if isHovered { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                }

                // System & Architecture Specs
                VStack(alignment: .leading, spacing: 8) {
                    Text("System & Runtime Environment")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)

                    VStack(spacing: 6) {
                        HStack {
                            Text("Operating System")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(ProcessInfo.processInfo.operatingSystemVersionString)
                                .font(.system(size: 11, weight: .medium))
                        }

                        HStack {
                            Text("Compositor Engine")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 27 ? "macOS 27 Native WindowServer" : "AppKit Legacy Reflow")
                                .font(.system(size: 11, weight: .medium))
                        }

                        HStack {
                            Text("Binary Architecture")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Universal ARM64 (Apple Silicon)")
                                .font(.system(size: 11, weight: .medium))
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                }

                // Reset Action
                Button(action: {
                    prefs.resetToDefaults()
                }) {
                    Text("Reset All Settings to Factory Defaults")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)

                Text("Copyright © 2026 Assoc. Prof. Dr. Mehmet Akif Cifci (SoftAI Yazılım). All rights reserved.")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(20)
        }
    }
}
