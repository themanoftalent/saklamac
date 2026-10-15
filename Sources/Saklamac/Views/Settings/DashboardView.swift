import SwiftUI
import AppKit

public struct DashboardView: View {
    @ObservedObject var prefs = PreferencesManager.shared
    @ObservedObject var notchDetector = NotchDetector.shared
    @StateObject private var preview = PreviewState(isCollapsed: MenuBarController.shared.currentState == .collapsed)

    private var isMacOS27: Bool {
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 27
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header Banner
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color.accentColor.opacity(0.85), Color.accentColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 54, height: 54)

                        Image(systemName: "menubar.rectangle")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("Saklamac Pro")
                                .font(.system(size: 17, weight: .bold))

                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)

                            Text("SYSTEM ACTIVE")
                                .font(.system(size: 9, weight: .heavy))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.18))
                                .foregroundColor(.green)
                                .cornerRadius(4)
                        }

                        Text(isMacOS27 ? "Operating via native WindowServer compositor on macOS 27+." : "Operating via native layout reflow engine.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("DEVELOPER")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
                        Text("Mehmet Akif Cifci")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.primary)
                        Text("TheManOfTalent")
                            .font(.system(size: 10))
                            .foregroundColor(.accentColor)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                )

                // Interactive Live Canvas
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Interactive Menu Bar Canvas")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Click chevron in canvas to test")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                    SimulatedMenuBarView(
                        isCollapsed: $preview.isCollapsed,
                        showAlwaysHidden: prefs.alwaysHiddenEnabled
                    )
                }

                // Display & Notch Hardware Geometry
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hardware & Display Intelligence")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        Image(systemName: notchDetector.currentNotchInfo.hasNotch ? "macbook.and.iphone" : "display")
                            .font(.system(size: 24))
                            .foregroundColor(notchDetector.currentNotchInfo.hasNotch ? .orange : .blue)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(notchDetector.currentNotchInfo.displayDescription)
                                .font(.system(size: 13, weight: .semibold))
                            Text(notchDetector.currentNotchInfo.hasNotch
                                 ? "Camera notch detected (\(Int(notchDetector.currentNotchInfo.notchWidth))px width). Saklamac Shelf prevents icon swallowing."
                                 : "Standard display without notch. Maximum menu bar real-estate available.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if notchDetector.currentNotchInfo.hasNotch {
                            Text("NOTCH AWARE")
                                .font(.system(size: 9, weight: .heavy))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.orange.opacity(0.18))
                                .foregroundColor(.orange)
                                .cornerRadius(4)
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                }

                // System & Performance Metrics Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    MetricCardView(
                        icon: "bolt.fill",
                        iconColor: .orange,
                        title: "Active Engine",
                        value: isMacOS27 ? "macOS 27 Native" : "Legacy Reflow"
                    )

                    MetricCardView(
                        icon: AccessibilityInventory.shared.isAuthorized ? "checkmark.shield.fill" : "exclamationmark.shield.fill",
                        iconColor: AccessibilityInventory.shared.isAuthorized ? .green : .yellow,
                        title: "Accessibility",
                        value: AccessibilityInventory.shared.isAuthorized ? "Authorized" : "Action Needed"
                    )

                    MetricCardView(
                        icon: "memorychip.fill",
                        iconColor: .purple,
                        title: "RAM Footprint",
                        value: "~14 MB"
                    )
                }

                // Quick Action Panel
                VStack(alignment: .leading, spacing: 10) {
                    Text("Instant Control Center")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)

                    HStack(spacing: 10) {
                        Button(action: {
                            MenuBarController.shared.toggle()
                            preview.isCollapsed = MenuBarController.shared.currentState == .collapsed
                            if prefs.showHUDNotifications {
                                HUDController.shared.show(
                                    message: preview.isCollapsed ? "Drawer Hidden" : "Drawer Expanded",
                                    systemImage: preview.isCollapsed ? "chevron.right" : "chevron.left"
                                )
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.left.arrow.right")
                                Text("Toggle Drawer")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .controlSize(.regular)

                        Button(action: {
                            FloatingShelfController.shared.toggle()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "menubar.arrow.down.rectangle")
                                Text("Toggle Shelf")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .controlSize(.regular)

                        Button(action: {
                            QuickSearchController.shared.toggle()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "magnifyingglass")
                                Text("Quick Search")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .controlSize(.regular)

                        Button(action: {
                            SoundManager.shared.playSound(named: prefs.expandSound.rawValue)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "speaker.wave.2.fill")
                                Text("Test Audio")
                            }
                            .frame(maxWidth: .infinity)
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
            .padding(20)
        }
    }
}

private struct MetricCardView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 13))
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
}
