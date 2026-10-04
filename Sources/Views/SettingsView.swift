import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    let calendar: CalendarService

    var body: some View {
        NavigationStack {
            Form {
                Section("Where you work") {
                    ForEach(WorkEnvironment.allCases) { env in
                        HStack(spacing: 12) {
                            Image(systemName: env == .office ? "building.2.fill" : "house.fill")
                                .foregroundStyle(.blue)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(env.displayName)
                                    .font(.subheadline.weight(.medium))
                                Text(env.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if settings.environment == env {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            settings.environment = env
                            settings.persist()
                        }
                    }
                }

                Section {
                    Toggle("Add resets to my calendar", isOn: Binding(
                        get: { settings.calendarWriteEnabled },
                        set: { newValue in
                            if newValue {
                                Task { await enableCalendarWrite() }
                            } else {
                                settings.calendarWriteEnabled = false
                                settings.persist()
                            }
                        }
                    ))
                    Text("When on, Nofesh writes 2-minute reset blocks into free slots so they actually happen. Requires calendar access.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if settings.calendarWriteEnabled {
                        Label("Calendar sync enabled", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else if settings.calendarPermissionRequested && calendar.permission == .denied {
                        Button("Open Settings to grant access") {
                            openSystemSettings()
                        }
                    }
                } header: {
                    Text("Calendar")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func enableCalendarWrite() async {
        let granted = await calendar.requestReadAccess()
        settings.calendarPermissionRequested = true
        settings.calendarWriteEnabled = granted
        settings.persist()
        if granted {
            calendar.refreshDay(.now)
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}