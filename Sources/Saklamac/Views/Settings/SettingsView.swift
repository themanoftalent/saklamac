import SwiftUI

public enum SettingsTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case apps = "App Manager"
    case shelf = "Floating Shelf"
    case gestures = "Gestures & Triggers"
    case shortcuts = "Shortcuts & HUD"
    case appearance = "Appearance & Density"
    case profiles = "Profiles & Presets"
    case pro = "Pro Features"
    case general = "General Settings"
    case about = "About"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .dashboard: return "gauge.medium"
        case .apps: return "square.stack.3d.up.fill"
        case .shelf: return "menubar.arrow.down.rectangle"
        case .gestures: return "hand.tap.fill"
        case .shortcuts: return "command"
        case .appearance: return "paintpalette.fill"
        case .profiles: return "square.stack.3d.forward.dottedline.fill"
        case .pro: return "crown.fill"
        case .general: return "gearshape.fill"
        case .about: return "info.circle.fill"
        }
    }

    public var category: String {
        switch self {
        case .dashboard, .apps, .shelf:
            return "OVERVIEW"
        case .gestures, .shortcuts, .appearance:
            return "EXPERIENCE & STYLE"
        case .profiles, .pro, .general, .about:
            return "SYSTEM & BRAND"
        }
    }
}

public final class SettingsViewState: ObservableObject {
    @Published public var selectedTab: SettingsTab

    public init(selectedTab: SettingsTab = .dashboard) {
        self.selectedTab = selectedTab
    }
}

public struct SettingsView: View {
    @StateObject private var viewState: SettingsViewState
    @ObservedObject var prefs = PreferencesManager.shared

    public init(selectedTab: SettingsTab = .dashboard) {
        _viewState = StateObject(wrappedValue: SettingsViewState(selectedTab: selectedTab))
    }

    public var body: some View {
        HStack(spacing: 0) {
            // Modern Acrylic Sidebar
            VStack(alignment: .leading, spacing: 0) {
                // Sidebar Header Branding
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.accentColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)

                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Saklamac")
                            .font(.system(size: 14, weight: .bold))
                        Text("PRO EDITION")
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundColor(.orange)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 14)

                Divider()

                // Nav Items Grouped by Category
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(["OVERVIEW", "EXPERIENCE & STYLE", "SYSTEM & BRAND"], id: \.self) { category in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(category)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.secondary.opacity(0.8))
                                    .padding(.horizontal, 14)
                                    .padding(.top, 6)

                                ForEach(SettingsTab.allCases.filter { $0.category == category }) { tab in
                                    SidebarButton(
                                        tab: tab,
                                        isSelected: viewState.selectedTab == tab,
                                        action: {
                                            viewState.selectedTab = tab
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Divider()

                // Footer Developer Attribution
                VStack(alignment: .leading, spacing: 4) {
                    Text("SOFTAI YAZILIM")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(.secondary)

                    Text(prefs.developerTitle)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(prefs.developerCredit)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
            .frame(width: 215)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.65))

            Divider()

            // Detail Content View
            ZStack {
                Color(NSColor.windowBackgroundColor)

                Group {
                    switch viewState.selectedTab {
                    case .dashboard:
                        DashboardView()
                    case .apps:
                        AppManagerView()
                    case .shelf:
                        FloatingShelfSettingsView()
                    case .gestures:
                        GesturesView()
                    case .shortcuts:
                        ShortcutsSettingsView()
                    case .appearance:
                        AppearanceSettingsView()
                    case .profiles:
                        ProfilesSettingsView()
                    case .pro:
                        ProSettingsView()
                    case .general:
                        GeneralSettingsView()
                    case .about:
                        AboutSettingsView()
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 820, height: 580)
    }
}

private struct SidebarButton: View {
    let tab: SettingsTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: tab.icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : .accentColor)
                    .frame(width: 20)

                Text(tab.rawValue)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .primary)

                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
    }
}
