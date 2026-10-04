import SwiftUI

struct PreflightView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    let block: RoutineBlock
    let onStart: (RoutineBlock) -> Void

    @State private var ready = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 6) {
                    Text(block.title)
                        .font(.title.bold())
                    Text("\(block.totalDuration / 60) minute reset")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                environmentPicker

                exercisePreview

                Spacer()

                Button {
                    onStart(block)
                } label: {
                    Label("Start Reset", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 20)
            .navigationTitle("Ready?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var environmentPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WHERE ARE YOU?")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                ForEach(WorkEnvironment.allCases) { env in
                    Button {
                        settings.environment = env
                        settings.persist()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: env == .office ? "building.2.fill" : "house.fill")
                                .font(.title2)
                            Text(env.displayName)
                                .font(.subheadline.weight(.semibold))
                            Text(env.detail)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(settings.environment == env ? Color.blue.opacity(0.15) : Color(.secondarySystemGroupedBackground))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(settings.environment == env ? Color.blue : Color.clear, lineWidth: 1.5)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var exercisePreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOU'LL DO")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            VStack(spacing: 0) {
                ForEach(Array(block.exercises.enumerated()), id: \.element.id) { index, exercise in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(Color.blue))
                        Text(exercise.name)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Text("\(exercise.duration / 60)m")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                    if index < block.exercises.count - 1 {
                        Divider().padding(.leading, 34)
                    }
                }
            }
            .padding(.horizontal, 14)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}