import SwiftUI

public struct OnboardingView: View {
    var onDismiss: () -> Void
    @StateObject private var preview = PreviewState(isCollapsed: false)

    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    private var isMacOS27: Bool {
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 27
    }

    public var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.12, green: 0.18, blue: 0.32), Color(red: 0.08, green: 0.10, blue: 0.20)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)

                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.orange)
                        Circle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 6, height: 6)
                    }
                }

                Text("Welcome to Saklamac")
                    .font(.system(size: 22, weight: .bold))

                Text("The Minimalist Menu Bar Manager for macOS • Hide clutter in seconds")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            // Interactive Simulated Menu Bar
            VStack(spacing: 6) {
                Text("LIVE DEMO: CLICK CHEVRON TO TEST")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.accentColor)

                SimulatedMenuBarView(isCollapsed: $preview.isCollapsed, showAlwaysHidden: true)
            }
            .padding(.horizontal, 8)

            // Step by Step Instructions
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.15))
                            .frame(width: 26, height: 26)
                        Text("1")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hold ⌘ (Command) Key")
                            .font(.system(size: 13, weight: .semibold))
                        Text("In macOS, holding Command lets you drag and reorder menu bar icons.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }

                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.15))
                            .frame(width: 26, height: 26)
                        Text("2")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Drag Icons Between the Chevron and Dot")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Icons placed to the left of the separator dot will be hidden when collapsed.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }

                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.15))
                            .frame(width: 26, height: 26)
                        Text("3")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Click Chevron or Press ⌘⌥H")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Click the chevron to toggle icons. Pro auto-hide and hotkeys are active!")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }

                if isMacOS27 && !AccessibilityInventory.shared.isAuthorized {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.accentColor)
                        Text("macOS 27+ Note: Grant Accessibility permission so Saklamac can detect where you place icons.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .padding(8)
                    .background(Color.accentColor.opacity(0.08))
                    .cornerRadius(6)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
            )

            // Button
            Button(action: {
                if isMacOS27 && !AccessibilityInventory.shared.isAuthorized {
                    AccessibilityInventory.shared.requestAuthorization()
                }
                onDismiss()
                MenuBarController.shared.collapse()
            }) {
                Text("Get Started")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(24)
        .frame(width: 540)
    }
}
