import SwiftUI

@MainActor
public final class ProfilesUIState: ObservableObject {
    @Published public var showingNewProfileSheet: Bool = false
    @Published public var newProfileName: String = ""
    @Published public var newProfileIcon: String = "briefcase.fill"
    @Published public var showingExportAlert: Bool = false
    @Published public var exportText: String = ""
    @Published public var showingImportSheet: Bool = false
    @Published public var importText: String = ""
    @Published public var importErrorMessage: String?

    public init() {}
}

public struct ProfilesSettingsView: View {
    @ObservedObject var profileManager = ProfileManager.shared
    @StateObject private var ui = ProfilesUIState()

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header Banner
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color.teal.opacity(0.85), Color.blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)

                        Image(systemName: "square.stack.3d.forward.dottedline.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Workspace Profiles & Presets")
                            .font(.system(size: 16, weight: .bold))
                        Text("Switch configurations instantly between Work, Deep Focus, and Presentation modes.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: { ui.showingNewProfileSheet = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                            Text("New Preset")
                        }
                    }
                    .controlSize(.regular)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                )

                // Profiles List
                VStack(alignment: .leading, spacing: 10) {
                    Text("Configured Profiles")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    VStack(spacing: 10) {
                        ForEach(profileManager.profiles) { profile in
                            ProfileCardRow(
                                profile: profile,
                                isActive: profile.id == profileManager.activeProfileId,
                                onSelect: {
                                    profileManager.activeProfileId = profile.id
                                },
                                onDuplicate: {
                                    profileManager.duplicate(profile: profile)
                                },
                                onDelete: {
                                    profileManager.delete(id: profile.id)
                                }
                            )
                        }
                    }
                }

                // Import / Export Card
                VStack(alignment: .leading, spacing: 10) {
                    Text("Backup & Sync")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    HStack(spacing: 12) {
                        Button(action: {
                            if let json = profileManager.exportConfigurationJSON() {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(json, forType: .string)
                                ui.exportText = json
                                ui.showingExportAlert = true
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export to Clipboard")
                            }
                        }
                        .controlSize(.regular)

                        Button(action: {
                            ui.importText = ""
                            ui.importErrorMessage = nil
                            ui.showingImportSheet = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.down")
                                Text("Import from JSON")
                            }
                        }
                        .controlSize(.regular)

                        Spacer()
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
        .sheet(isPresented: $ui.showingNewProfileSheet) {
            VStack(spacing: 16) {
                Text("Create New Preset")
                    .font(.system(size: 16, weight: .bold))

                TextField("Preset Name (e.g. Coding Mode)", text: $ui.newProfileName)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Cancel") { ui.showingNewProfileSheet = false }
                    Spacer()
                    Button("Create") {
                        if !ui.newProfileName.trimmingCharacters(in: .whitespaces).isEmpty {
                            profileManager.createProfile(name: ui.newProfileName, icon: ui.newProfileIcon)
                            ui.newProfileName = ""
                            ui.showingNewProfileSheet = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(ui.newProfileName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding(24)
            .frame(width: 360)
        }
        .sheet(isPresented: $ui.showingImportSheet) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Import Preset Configuration")
                    .font(.system(size: 16, weight: .bold))

                Text("Paste your exported Saklamac JSON payload below:")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                TextEditor(text: $ui.importText)
                    .font(.system(size: 11, design: .monospaced))
                    .frame(height: 140)
                    .border(Color(NSColor.separatorColor))

                if let err = ui.importErrorMessage {
                    Text(err)
                        .font(.system(size: 11))
                        .foregroundColor(.red)
                }

                HStack {
                    Button("Cancel") { ui.showingImportSheet = false }
                    Spacer()
                    Button("Apply Import") {
                        if profileManager.importConfigurationJSON(ui.importText) {
                            ui.showingImportSheet = false
                        } else {
                            ui.importErrorMessage = "Invalid JSON structure. Please check and try again."
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(24)
            .frame(width: 440)
        }
        .alert("Configuration Exported", isPresented: $ui.showingExportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your complete preset configuration has been copied to your clipboard as JSON.")
        }
    }
}

private struct ProfileCardRow: View {
    let profile: AppProfile
    let isActive: Bool
    let onSelect: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: profile.icon)
                .font(.system(size: 20))
                .foregroundColor(isActive ? .accentColor : .secondary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(profile.name)
                        .font(.system(size: 13, weight: .semibold))

                    if isActive {
                        Text("ACTIVE")
                            .font(.system(size: 9, weight: .heavy))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.18))
                            .foregroundColor(.accentColor)
                            .cornerRadius(4)
                    }

                    if profile.isBuiltIn {
                        Text("BUILT-IN")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.15))
                            .foregroundColor(.secondary)
                            .cornerRadius(4)
                    }
                }

                Text(profile.description.isEmpty ? "Custom configured profile." : profile.description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !isActive {
                Button("Activate", action: onSelect)
                    .controlSize(.small)
            }

            Button(action: onDuplicate) {
                Image(systemName: "doc.on.doc")
            }
            .help("Duplicate Preset")
            .controlSize(.small)

            if !profile.isBuiltIn {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .help("Delete Preset")
                .controlSize(.small)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isActive ? Color.accentColor.opacity(0.08) : Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isActive ? Color.accentColor.opacity(0.4) : Color.clear, lineWidth: 1.5)
        )
    }
}
