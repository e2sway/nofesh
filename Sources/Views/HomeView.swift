import SwiftUI
import SwiftData
import EventKit

struct HomeView: View {
    @Environment(AppContent.self) private var content: AppContent
    @Environment(AppSettings.self) private var settings
    @Query(sort: \CompletionRecord.completedAt, order: .reverse) private var completions: [CompletionRecord]

    @State private var calendar = CalendarService()
    @State private var selectedBlock: RoutineBlock?
    @State private var showingPreflight = false
    @State private var showingSettings = false

    private var todaysBlocks: [(RoutineBlock, Date)] {
        let calendarNow = Calendar.current
        return content.library.blocks.map { block in
            let (h, m) = timeComponents(from: block.suggestedTime)
            let assigned = slot(near: h, minute: m, for: block)
            return (block, assigned)
        }
    }

    private var nextBlock: (RoutineBlock, Date)? {
        let now = Date()
        return todaysBlocks
            .filter { $0.1 > now.addingTimeInterval(-60) }
            .min { $0.1 < $1.1 }
    }

    private var completedToday: [String] {
        let start = Calendar.current.startOfDay(for: .now)
        return completions
            .filter { $0.completedAt >= start }
            .map(\.blockID)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    if let next = nextBlock {
                        nextCard(next.0, at: next.1)
                    } else {
                        doneForToday
                    }
                    timeline
                    blocksSection
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingPreflight, onDismiss: { selectedBlock = nil }) {
                if let block = selectedBlock {
                    PreflightView(block: block) { block in
                        showingPreflight = false
                        selectedBlock = block
                    }
                }
            }
            .fullScreenCover(item: $selectedBlock) { block in
                PlayerView(block: block)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(calendar: calendar)
            }
        }
        .task {
            calendar.refreshDay(.now)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(todayTitle)
                    .font(.title2.weight(.semibold))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .frame(width: 40, height: 40)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 8)
    }

    private var todayTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: .now)
    }

    private var subtitle: String {
        guard !completions.isEmpty else {
            return "Three 2-minute resets for your body."
        }
        let done = completedToday.count
        return "\(done) of 3 resets done today."
    }

    private func nextCard(_ block: RoutineBlock, at date: Date) -> some View {
        Button {
            selectedBlock = block
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("UP NEXT")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    Text(shortTime(date))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                }
                Text(block.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                Text("\(block.totalDuration / 60) min · \(block.position.displayName)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                HStack {
                    Spacer()
                    Image(systemName: "play.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(18)
            .background(
                LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var doneForToday: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundStyle(.green)
            VStack(alignment: .leading) {
                Text("The day's all reset.")
                    .font(.headline)
                Text("See you tomorrow.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("YOUR DAY")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                if calendar.permission == .granted {
                    Text("Synced")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                }
            }
            .padding(.top, 4)

            VStack(spacing: 0) {
                ForEach(calendar.events.isEmpty ? [] : calendar.events, id: \.calendarItemIdentifier) { event in
                    eventRow(for: event)
                }
                if calendar.events.isEmpty {
                    ForEach(Array(todaysBlocks.enumerated()), id: \.element.0.id) { _, item in
                        blockRow(item.0, at: item.1)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func eventRow(for event: EKEvent) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(event.calendar.cgColor))
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title ?? "Busy")
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text("\(shortTime(event.startDate)) – \(shortTime(event.endDate))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func blockRow(_ block: RoutineBlock, at date: Date) -> some View {
        Button {
            selectedBlock = block
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                VStack(alignment: .leading, spacing: 2) {
                    Text(block.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("\(block.totalDuration / 60) min · Suggested \(shortTime(date))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private var blocksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TODAY'S RESETS")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            ForEach(todaysBlocks, id: \.0.id) { item in
                BlockCard(block: item.0, at: item.1, done: completedToday.contains(item.0.id)) {
                    selectedBlock = item.0
                }
            }
        }
    }

    private func slot(near hour: Int, minute: Int, for block: RoutineBlock) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        comps.hour = hour
        comps.minute = minute
        comps.second = 0
        let desired = Calendar.current.date(from: comps) ?? .now

        guard calendar.permission == .granted, !calendar.gaps.isEmpty else {
            return desired
        }

        let tolerance: TimeInterval = 45 * 60
        let windowStart = desired.addingTimeInterval(-tolerance)
        let windowEnd = desired.addingTimeInterval(tolerance)
        return calendar.gaps
            .filter { $0.fitsBlock(block.totalDuration / 60) }
            .first { $0.start >= windowStart && $0.start <= windowEnd }?
            .start ?? desired
    }

    private func timeComponents(from string: String) -> (Int, Int) {
        let parts = string.split(separator: ":").map { Int($0) ?? 0 }
        return (parts.first ?? 10, parts.count > 1 ? parts[1] : 0)
    }

    private func shortTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}

struct BlockCard: View {
    let block: RoutineBlock
    let at: Date
    let done: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(block.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(block.focus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    if done {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.green)
                    } else {
                        Text(shortTimeAt)
                            .font(.subheadline.weight(.semibold))
                        Text("\(block.totalDuration / 60) min")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                if !done {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.accentColor.opacity(0.15), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var shortTimeAt: String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: at)
    }
}