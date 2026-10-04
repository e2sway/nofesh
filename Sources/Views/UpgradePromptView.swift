import SwiftUI

struct UpgradePromptView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    let onEnable: () async -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 96, height: 96)
                Image(systemName: "bells.and.waves.left.and.right.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 8) {
                Text("Want Nofesh to keep an eye on the clock?")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("We'll read your calendar for free gaps and nudge you when it's time for the next reset. It still gets out of your way instantly.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(alignment: .leading, spacing: 14) {
                benefitRow(icon: "calendar", text: "Finds your free 2-minute gaps automatically")
                benefitRow(icon: "bell.fill", text: "Nudges you gently, only during your work hours")
                benefitRow(icon: "hand.raised.fill", text: "Nothing you approve ever happens without consent")
            }
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 10) {
                Button {
                    Task {
                        await onEnable()
                        dismiss()
                    }
                } label: {
                    Label("Enable resets & nudges", systemImage: "checkmark")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                Button {
                    settings.calendarPermissionRequested = true
                    settings.persist()
                    dismiss()
                } label: {
                    Text("Maybe later")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .padding(.top, 20)
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
        }
    }
}