import SwiftUI

public struct SimulatedMenuBarView: View {
    @Binding var isCollapsed: Bool
    var showAlwaysHidden: Bool

    public init(isCollapsed: Binding<Bool>, showAlwaysHidden: Bool = true) {
        self._isCollapsed = isCollapsed
        self.showAlwaysHidden = showAlwaysHidden
    }

    public var body: some View {
        VStack(spacing: 8) {
            // Simulated Menu Bar
            HStack(spacing: 12) {
                // Left side: Apple & app menus
                HStack(spacing: 10) {
                    Image(systemName: "applelogo")
                        .font(.system(size: 13))
                    Text("Saklamac")
                        .font(.system(size: 12, weight: .semibold))
                    Text("File")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text("Edit")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Right side: Menu Bar Items
                HStack(spacing: 8) {
                    // Always Hidden Section (Leftmost)
                    if showAlwaysHidden {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.red.opacity(0.8))
                            Image(systemName: "bolt.badge.clock.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.orange.opacity(0.8))
                        }
                        .padding(.horizontal, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.red.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )

                        // Always Hidden Separator
                        VStack(spacing: 2) {
                            Circle().fill(Color.secondary).frame(width: 2.5, height: 2.5)
                            Circle().fill(Color.secondary).frame(width: 2.5, height: 2.5)
                        }
                        .frame(width: 8)
                    }

                    // Collapsible Hidden Section
                    if !isCollapsed {
                        HStack(spacing: 8) {
                            Image(systemName: "cloud.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Image(systemName: "music.note")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Image(systemName: "externaldrive.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentColor.opacity(0.12))
                        )
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.9)),
                            removal: .opacity.combined(with: .scale(scale: 0.9))
                        ))
                    }

                    // Separator Dot
                    Circle()
                        .fill(Color.primary.opacity(0.7))
                        .frame(width: 4, height: 4)

                    // Toggle Button (Interactive!)
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            isCollapsed.toggle()
                        }
                    }) {
                        HStack(spacing: 2) {
                            Image(systemName: isCollapsed ? "chevron.right" : "chevron.left")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.accentColor)
                        }
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentColor.opacity(0.18))
                        )
                    }
                    .buttonStyle(.plain)

                    // Always Visible Section (Rightmost)
                    HStack(spacing: 8) {
                        Image(systemName: "wifi")
                            .font(.system(size: 11))
                        Image(systemName: "battery.100")
                            .font(.system(size: 11))
                        Image(systemName: "switch.2")
                            .font(.system(size: 11))
                        Text("19:00")
                            .font(.system(size: 11, weight: .medium))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            )

            // Explanatory label below
            HStack(spacing: 16) {
                if showAlwaysHidden {
                    HStack(spacing: 4) {
                        Circle().fill(Color.red).frame(width: 6, height: 6)
                        Text("Permanently Hidden")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }

                HStack(spacing: 4) {
                    Circle().fill(Color.accentColor).frame(width: 6, height: 6)
                    Text("Collapsible Section")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 4) {
                    Circle().fill(Color.green).frame(width: 6, height: 6)
                    Text("Always Visible")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
