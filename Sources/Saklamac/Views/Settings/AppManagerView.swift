import SwiftUI
import AppKit

public struct AppManagerItem: Identifiable, Equatable {
    public var id: String { bundleIdentifier }
    public let bundleIdentifier: String
    public let name: String
    public let icon: NSImage
    public let isRunning: Bool
}

public enum AppZoneFilter: String, CaseIterable, Identifiable {
    case all = "All Apps"
    case visible = "Visible Zone"
    case drawer = "Drawer"
    case ghost = "Ghost Zone"

    public var id: String { rawValue }
}

@MainActor
public final class AppManagerState: ObservableObject {
    @Published public var searchText: String = ""
    @Published public var selectedFilter: AppZoneFilter = .all
    @Published public var apps: [AppManagerItem] = []
    @Published public var isLoading: Bool = false

    public init() {
        refreshApps()
    }

    public func refreshApps() {
        isLoading = true
        let ownBundle = Bundle.main.bundleIdentifier ?? "com.saklamac.app"

        let running = NSWorkspace.shared.runningApplications
            .filter { $0.bundleIdentifier != ownBundle && $0.bundleURL?.pathExtension == "app" }

        var list: [AppManagerItem] = []
        var seen = Set<String>()

        for app in running {
            guard let bundleId = app.bundleIdentifier, !seen.contains(bundleId) else { continue }
            seen.insert(bundleId)

            let name = app.localizedName ?? bundleId
            let icon: NSImage
            if let url = app.bundleURL {
                icon = NSWorkspace.shared.icon(forFile: url.path)
            } else {
                icon = NSImage(systemSymbolName: "app", accessibilityDescription: nil) ?? NSImage()
            }

            list.append(AppManagerItem(
                bundleIdentifier: bundleId,
                name: name,
                icon: icon,
                isRunning: true
            ))
        }

        self.apps = list.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        self.isLoading = false
    }
}

public struct AppManagerView: View {
    @StateObject private var state = AppManagerState()
    @ObservedObject var prefs = PreferencesManager.shared

    private var filteredApps: [AppManagerItem] {
        var base = state.apps
        if !state.searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = state.searchText.lowercased()
            base = base.filter {
                $0.name.lowercased().contains(q) || $0.bundleIdentifier.lowercased().contains(q)
            }
        }

        switch state.selectedFilter {
        case .all:
            return base
        case .visible:
            return base.filter { prefs.getCustomZone(for: $0.bundleIdentifier) == .visible }
        case .drawer:
            return base.filter {
                let z = prefs.getCustomZone(for: $0.bundleIdentifier)
                return z == nil || z == .hidden
            }
        case .ghost:
            return base.filter { prefs.getCustomZone(for: $0.bundleIdentifier) == .alwaysHidden }
        }
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Search & Controls Bar
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search running apps...", text: $state.searchText)
                        .textFieldStyle(.plain)
                    if !state.searchText.isEmpty {
                        Button(action: { state.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                )

                Button(action: {
                    state.refreshApps()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .help("Refresh running apps")
                .controlSize(.regular)

                if !prefs.customAppZones.isEmpty {
                    Button(action: {
                        prefs.customAppZones.removeAll()
                        MenuBarController.shared.expand()
                    }) {
                        Text("Reset Overrides")
                            .font(.system(size: 11))
                    }
                    .controlSize(.small)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            // Zone Category Filter Pills
            HStack(spacing: 8) {
                ForEach(AppZoneFilter.allCases) { filter in
                    Button(action: { state.selectedFilter = filter }) {
                        Text(filter.rawValue)
                            .font(.system(size: 11, weight: state.selectedFilter == filter ? .semibold : .regular))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(state.selectedFilter == filter ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                            )
                            .foregroundColor(state.selectedFilter == filter ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Text("\(filteredApps.count) apps")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)

            Divider()

            // Apps List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredApps) { item in
                        AppRowView(item: item, prefs: prefs)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }
}

private struct AppRowView: View {
    let item: AppManagerItem
    @ObservedObject var prefs: PreferencesManager

    private var currentSection: MenuBarSection {
        if let custom = prefs.getCustomZone(for: item.bundleIdentifier) {
            return custom
        }
        return .hidden
    }

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(nsImage: item.icon)
                .resizable()
                .frame(width: 30, height: 30)

            // Name & Bundle
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                Text(item.bundleIdentifier)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Quick focus button
            Button(action: {
                if let app = NSRunningApplication.runningApplications(withBundleIdentifier: item.bundleIdentifier).first {
                    app.activate()
                }
            }) {
                Image(systemName: "arrow.up.forward.app")
                    .font(.system(size: 12))
            }
            .help("Activate \(item.name)")
            .controlSize(.small)

            // Segmented Picker
            Picker("", selection: Binding(
                get: { currentSection },
                set: { newSection in
                    prefs.setCustomZone(for: item.bundleIdentifier, section: newSection)
                    MenuBarController.shared.expand()
                }
            )) {
                Text("Visible").tag(MenuBarSection.visible)
                Text("Drawer").tag(MenuBarSection.hidden)
                Text("Ghost Zone").tag(MenuBarSection.alwaysHidden)
            }
            .pickerStyle(.segmented)
            .frame(width: 240)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
}
