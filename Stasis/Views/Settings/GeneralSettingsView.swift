import Defaults
import SwiftUI

struct GeneralSettingsView: View {
    @Default(.appLanguage) var appLanguage
    @Default(.launchAtLogin) var launchAtLogin
    @Default(.batteryPercentageDisplayLocation) var batteryPercentageDisplayLocation
    @Default(.showBatteryStateInStatusIcon) var showBatteryStateInStatusIcon
    @Default(.disableNotifications) var disableNotifications
    @Default(.showChargingStatusChangedNotification) var showChargingStatusChangedNotification
    @State private var restartError: String?

    var body: some View {
        Form {
            Section {
                Picker("Language", selection: $appLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
            } header: {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Language")
                    Text("Changing the language automatically restarts Stasis.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Startup") {
                Toggle("Launch at login", isOn: $launchAtLogin)
            }

            Section {
                Picker("Show percentage", selection: $batteryPercentageDisplayLocation) {
                    Text("Hidden").tag(PercentageDisplayLocation.hidden)
                    Text("Next to icon").tag(PercentageDisplayLocation.nextToIcon)
                    Text("Inside icon").tag(PercentageDisplayLocation.insideIcon)
                }
                Toggle("Show battery state", isOn: $showBatteryStateInStatusIcon)
            } header: {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Menu Bar Icon")
                    Text(
                        "Display battery percentage next to or inside the menu bar icon."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }

            Section {
                Toggle("Disable all notifications", isOn: $disableNotifications)
                Toggle("Charging status changed", isOn: $showChargingStatusChangedNotification)
                    .disabled(disableNotifications)
            } header: {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Notifications")
                    Text("Control when Stasis sends you notifications.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .contentMargins(.top, 0)
        .onChange(of: launchAtLogin) { _, newValue in
            LaunchAtLoginService.shared.setLaunchAtLogin(newValue)
        }
        .onChange(of: appLanguage) { _, newValue in
            AppLanguage.apply(newValue)
            Task { @MainActor in
                do {
                    try await AppLanguage.relaunch()
                } catch {
                    restartError = error.localizedDescription
                }
            }
        }
        .alert(
            "Restart Failed",
            isPresented: Binding(
                get: { restartError != nil },
                set: { if !$0 { restartError = nil } }
            )
        ) {
            Button("Ok") { restartError = nil }
        } message: {
            VStack(alignment: .leading) {
                Text("Stasis could not restart automatically. Quit and reopen Stasis to apply the language change.")
                Text(restartError ?? "")
            }
        }
    }
}

#Preview {
    GeneralSettingsView()
}
