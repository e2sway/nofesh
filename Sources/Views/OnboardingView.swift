import SwiftUI

struct OnboardingView: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Two minutes that undo your desk.")
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text("Short, silent resets for the parts of you sitting doesn't treat well.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            onboardingContent

            Spacer()
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var onboardingContent: some View {
        if settings.painFocus == nil {
            painCapture
        } else if !settings.hasCompletedOnboarding {
            environmentCapture
        } else {
            EmptyView()
        }
    }

    private var painCapture: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Which one feels the tightest by 3pm?")
                .font(.headline)

            ForEach(PainFocus.allCases) { focus in
                Button {
                    settings.painFocus = focus
                    withAnimation(.easeInOut(duration: 0.25)) { settings.painFocus = focus }
                } label: {
                    HStack {
                        Image(systemName: symbol(for: focus))
                            .font(.title3)
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 32)
                        Text(focus.displayName)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var environmentCapture: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Where do you do most of your work?")
                .font(.headline)

            ForEach(WorkEnvironment.allCases) { env in
                Button {
                    settings.environment = env
                    withAnimation {
                        settings.hasCompletedOnboarding = true
                    }
                    settings.persist()
                } label: {
                    HStack {
                        Image(systemName: env == .office ? "building.2.fill" : "house.fill")
                            .font(.title3)
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 32)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(env.displayName)
                                .font(.subheadline.weight(.medium))
                            Text(env.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            Text("You can change this anytime.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
    }

    private func symbol(for focus: PainFocus) -> String {
        switch focus {
        case .lowerBack: return "figure.walk"
        case .hips: return "figure.cross.training"
        case .neck: return "figure.mind.and.body"
        }
    }
}