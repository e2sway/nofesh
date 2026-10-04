import SwiftUI
import SwiftData

struct PlayerView: View {
    let block: RoutineBlock

    @Environment(AppSettings.self) private var settings
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var engine = SessionEngine()
    @State private var timer: Timer?
    @State private var showingUpgrade = false

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                header
                Spacer(minLength: 0)
                visualStage
                Spacer(minLength: 0)
                cuePanel
                controls
            }
        }
        .onAppear {
            engine.load(block)
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .animation(.easeInOut(duration: 0.35), value: engine.currentExerciseID)
        .fullScreenCover(isPresented: $showingUpgrade) {
            UpgradePromptView {
                await enableCalendarAndNudges()
            }
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.4)],
                startPoint: .top, endPoint: .bottom
            )
            MetroBackground()
                .ignoresSafeArea()
                .opacity(0.15)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(block.title)
                    .font(.headline)
                if engine.isFinished {
                    Text("Reset complete")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Text(engine.sectionLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if !engine.isFinished {
                Button {
                    confirmQuit()
                } label: {
                    Image(systemName: "xmark")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 34, height: 34)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var visualStage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
            ExerciseVisualView(
                visual: engine.currentVisual,
                position: engine.currentPosition,
                isActive: !engine.isFinished
            )
            .scaleEffect(x: engine.currentMirrored ? -1 : 1, y: 1)
            .animation(.easeInOut(duration: 0.3), value: engine.currentMirrored)

            progressDots
                .padding(.top, 14)

            if !engine.isFinished {
                VStack {
                    Spacer()
                    ScrimCueView(title: engine.currentTitle, cue: engine.currentCue)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .frame(width: 300, height: 380)
    }

    private var progressDots: some View {
        VStack {
            HStack(spacing: 6) {
                ForEach(Array(engine.unitIDs.enumerated()), id: \.element) { index, _ in
                    Circle()
                        .fill(index < engine.currentUnitIndex ? Color.blue : index == engine.currentUnitIndex ? Color.blue.opacity(0.6) : Color(.systemGray4))
                        .frame(width: 8, height: 8)
                }
            }
            Spacer()
        }
    }

    private var cuePanel: some View {
        VStack(spacing: 10) {
            if let why = engine.currentWhy, engine.isFinished == false {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Why: \(why)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            }
        }
    }

    private struct ScrimCueView: View {
        let title: String
        let cue: String

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(cue)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.0), .black.opacity(0.55), .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(28, antialiased: true)
        }
    }

    private var controls: some View {
        HStack {
            if engine.isFinished {
                Button {
                    finishAndRecord()
                } label: {
                    Label("Mark Done", systemImage: "checkmark")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            } else {
                Text(engine.timeRemainingLabel)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .padding(.top, 8)
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            engine.tick(interval: 0.1)
        }
    }

    private func confirmQuit() {
        timer?.invalidate()
        if engine.isFinished {
            finishAndRecord()
        } else {
            dismiss()
        }
    }

    private func finishAndRecord() {
        timer?.invalidate()
        let now = Date()
        for exercise in block.exercises {
            let record = CompletionRecord(
                blockID: block.id,
                exerciseID: exercise.id,
                completedAt: now,
                environment: settings.environment.rawValue
            )
            modelContext.insert(record)
        }
        try? modelContext.save()

        if settings.calendarWriteEnabled {
            Task { await writeToCalendar() }
        }

        let wasFirstCompletion = !settings.hasCompletedRoutine
        settings.hasCompletedRoutine = true
        settings.persist()

        scheduleNextNudge()

        if wasFirstCompletion && !settings.calendarPermissionRequested {
            showingUpgrade = true
        } else {
            dismiss()
        }
    }

    private func scheduleNextNudge() {
        let calendar = CalendarService()
        calendar.refreshDay(.now)
        let fallback = Date().addingTimeInterval(60 * 60 * 2)
        let target = timetableCandidate(from: calendar) ?? fallback
        NotificationService.scheduleNudge(
            blockID: block.id,
            title: "Nofesh: \(block.title)",
            body: "2-minute reset coming up. It slides right into your day.",
            at: target
        )
    }

    private func enableCalendarAndNudges() async {
        let calendar = CalendarService()
        let granted = await calendar.requestReadAccess()
        settings.calendarPermissionRequested = true
        if granted {
            settings.calendarWriteEnabled = true
        }
        settings.persist()
        _ = await NotificationService.requestPermission()
        scheduleNextNudge()
        dismiss()
    }

    private func timetableCandidate(from calendar: CalendarService) -> Date? {
        guard calendar.permission == .granted,
              let gap = calendar.gaps.filter({ $0.fitsBlock(block.totalDuration / 60) }).first
        else { return nil }
        return gap.start
    }

    private func writeToCalendar() async {
        let calendar = CalendarService()
        guard await calendar.requestReadAccess() else { return }
        let target = Date().addingTimeInterval(60 * 60)
        for exercise in block.exercises {
            let title = "Nofesh: \(exercise.name)"
            let notes = exercise.segments?.map(\.cue).joined(separator: "\n\n") ?? ""
            _ = await calendar.writeBlock(
                title: title,
                notes: notes,
                at: target,
                duration: TimeInterval(exercise.duration)
            )
        }
    }
}

struct SessionEngine {
    struct Unit: Identifiable {
        let id = UUID().uuidString
        let exercise: Exercise
        let segmentTitle: String
        let cue: String
        let duration: TimeInterval
        let mirrored: Bool
    }

    private(set) var units: [Unit] = []
    private(set) var currentIndex = 0
    private(set) var remaining: TimeInterval = 0
    private(set) var block: RoutineBlock?

    var unitIDs: [String] { units.map(\.id) }
    var currentUnitIndex: Int { Swift.min(currentIndex, max(0, units.count - 1)) }

    var isFinished: Bool { currentIndex >= units.count }
    var currentUnit: Unit? {
        guard !units.isEmpty, currentIndex < units.count else { return nil }
        return units[currentIndex]
    }

    var currentExerciseID: String? { currentUnit?.exercise.id }
    var currentTitle: String { currentUnit?.segmentTitle ?? block?.title ?? "" }
    var currentCue: String { currentUnit?.cue ?? "" }
    var currentPosition: Position { currentUnit?.exercise.position ?? (block?.position ?? .seated) }
    var currentVisual: ExerciseVisual { currentUnit?.exercise.visual ?? .avatar(pose: "neutral") }
    var currentMirrored: Bool { currentUnit?.mirrored ?? false }
    var currentWhy: String? { currentUnit?.exercise.whyItHelps }
    var sectionLabel: String {
        guard let block else { return "" }
        return "\(currentIndex + 1)/\(units.count) · \(block.title)"
    }

    var timeRemainingLabel: String {
        let total = Int(remaining.rounded(.up))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    mutating func load(_ block: RoutineBlock) {
        self.block = block
        units = []
        for exercise in block.exercises {
            if let segments = exercise.segments, !segments.isEmpty {
                for segment in segments {
                    units.append(Unit(
                        exercise: exercise,
                        segmentTitle: segment.title,
                        cue: segment.cue,
                        duration: TimeInterval(segment.duration),
                        mirrored: segment.isMirrored(false)
                    ))
                }
            } else {
                units.append(Unit(
                    exercise: exercise,
                    segmentTitle: exercise.name,
                    cue: "",
                    duration: TimeInterval(exercise.duration),
                    mirrored: false
                ))
            }
        }
        currentIndex = 0
        remaining = units.first?.duration ?? 0
    }

    mutating func tick(interval: TimeInterval) {
        guard !units.isEmpty else { return }
        remaining -= interval
        if remaining <= 0 {
            currentIndex += 1
            if currentIndex < units.count {
                remaining = units[currentIndex].duration
            } else {
                remaining = 0
            }
        }
    }
}

private struct MetroBackground: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                for i in 0..<12 {
                    let x = (t * 12 + CGFloat(i) * 90).truncatingRemainder(dividingBy: size.width + 200) - 100
                    let y = CGFloat(i * 60 + 20)
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: y))
                    path.addLine(to: CGPoint(x: x - 60, y: y + 40))
                    context.stroke(
                        path,
                        with: .color(Color.blue.opacity(0.5)),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                }
            }
        }
    }
}