import Foundation
import EventKit
import Combine
import Observation

enum CalendarPermissionState: Equatable {
    case notDetermined
    case denied
    case granted
}

struct DayGap: Identifiable, Equatable {
    var id: String { "\(start.timeIntervalSinceReferenceDate)-\(end.timeIntervalSinceReferenceDate)" }
    var start: Date
    var end: Date

    var duration: TimeInterval { end.timeIntervalSince(start) }

    func fitsBlock(_ minutes: Int) -> Bool {
        duration >= TimeInterval(minutes * 60)
    }
}

@Observable
final class CalendarService {
    private let store = EKEventStore()

    var permission: CalendarPermissionState = .notDetermined
    var events: [EKEvent] = []
    var gaps: [DayGap] = []

    func permissionStatus() -> CalendarPermissionState {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .fullAccess, .writeOnly, .authorized:
            return .granted
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }

    func requestReadAccess() async -> Bool {
        permission = permissionStatus()
        guard permission == .notDetermined else {
            return permission == .granted
        }
        do {
            let granted = try await store.requestFullAccessToEvents()
            permission = granted ? .granted : .denied
            return granted
        } catch {
            permission = .denied
            return false
        }
    }

    func refreshDay(_ day: Date) {
        permission = permissionStatus()
        guard permission == .granted else {
            events = []
            gaps = []
            return
        }

        let start = Calendar.current.startOfDay(for: day)
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return }

        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        events = store.events(matching: predicate).sorted { $0.startDate < $1.startDate }

        let dayStart = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: start) ?? start
        let dayEnd = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: start) ?? end

        var busy = events
            .filter { !$0.isAllDay && $0.startDate < dayEnd && $0.endDate > dayStart }
            .map { ClosedRange(uncheckedBounds: ($0.startDate, $0.endDate)) }

        busy.sort { $0.lowerBound < $1.lowerBound }

        var result: [DayGap] = []
        var cursor = dayStart
        for range in busy {
            if range.lowerBound > cursor {
                result.append(DayGap(start: cursor, end: min(range.lowerBound, dayEnd)))
            }
            cursor = max(cursor, range.upperBound)
        }
        if cursor < dayEnd {
            result.append(DayGap(start: cursor, end: dayEnd))
        }
        gaps = result.filter { $0.duration >= 90 }
    }

    func writeBlock(title: String, notes: String, at date: Date, duration: TimeInterval) async -> Result<Void, Error> {
        let calendar = store.defaultCalendarForNewEvents
        let event = EKEvent(eventStore: store)
        event.title = title
        event.notes = notes
        event.calendar = calendar
        event.startDate = date
        event.endDate = date.addingTimeInterval(duration)

        let rule = EKRecurrenceRule(
            recurrenceWith: .daily,
            interval: 1,
            end: nil
        )
        event.addRecurrenceRule(rule)

        do {
            try store.save(event, span: .futureEvents)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}