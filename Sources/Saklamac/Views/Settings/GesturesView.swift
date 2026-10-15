import SwiftUI

public struct GesturesView: View {
    @ObservedObject var prefs = PreferencesManager.shared

    let intervals: [(Double, String)] = [
        (1.0, "1 second"),
        (2.0, "2 seconds"),
        (3.0, "3 seconds"),
        (5.0, "5 seconds (Default)"),
        (10.0, "10 seconds"),
        (15.0, "15 seconds"),
        (30.0, "30 seconds")
    ]

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Section 1: Hover Gestures
                VStack(alignment: .leading, spacing: 10) {
                    Text("Mouse Hover Gestures")
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

                        if prefs.hoverToExpand {
                            Divider()

                            HStack {
                                Text("Hover Dwell Time:")
                                    .font(.system(size: 12))
                                Spacer()
                                Text(String(format: "%.1f seconds", prefs.hoverDwellTime))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }

                            Slider(value: $prefs.hoverDwellTime, in: 0.1...1.5, step: 0.1)
                                .accentColor(.accentColor)
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(NSColor.controlBackgroundColor))
                    )
                }

                // Section 2: Trackpad & Mouse Wheel Gestures
                VStack(alignment: .leading, spacing: 10) {
                    Text("Trackpad & Scroll Gestures")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    VStack(spacing: 12) {
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Scroll / Swipe on Menu Bar")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Swipe horizontally or scroll vertically anywhere across the menu bar to toggle the drawer.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $prefs.scrollGestureEnabled)
                                .labelsHidden()
                                .toggleStyle(.switch)
                        }

                        Divider()

                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Click Empty Space to Reveal")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Clicking on an empty area of the menu bar expands or collapses the drawer.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $prefs.emptyClickGestureEnabled)
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

                // Section 3: Smart Auto-Hide
                VStack(alignment: .leading, spacing: 10) {
                    Text("Smart Auto-Hide")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    VStack(spacing: 12) {
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Auto-Collapse Inactivity Timer")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Automatically collapses your hidden icons after a specified duration of inactivity.")
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
                                Text("Inactivity Timeout:")
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

                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.shield")
                                    .foregroundColor(.green)
                                    .font(.system(size: 12))
                                Text("Cursor Protection is active: The drawer will never collapse while your mouse is interacting with menu bar icons.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)
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
