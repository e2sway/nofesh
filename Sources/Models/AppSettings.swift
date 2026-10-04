import Foundation
import Observation

enum WorkEnvironment: String, CaseIterable, Codable, Identifiable {
    case office
    case wfh

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .office: return "Office Mode"
        case .wfh: return "WFH Mode"
        }
    }

    var detail: String {
        switch self {
        case .office: return "Discreet, seated, zero floor space"
        case .wfh: return "Standing allowed, full freedom"
        }
    }
}

enum PainFocus: String, CaseIterable, Codable, Identifiable {
    case lowerBack
    case hips
    case neck

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lowerBack: return "Lower back"
        case .hips: return "Hips"
        case .neck: return "Neck"
        }
    }
}

@Observable
final class AppSettings {
    var environment: WorkEnvironment = .office
    var calendarWriteEnabled: Bool = false
    var calendarPermissionRequested: Bool = false
    var encouragementsMuted: Bool = false
    var hasCompletedOnboarding: Bool = false
    var hasCompletedRoutine: Bool = false
    var painFocus: PainFocus? = nil

    private enum Keys {
        static let environment = "settings.environment"
        static let calendarWrite = "settings.calendarWrite"
        static let permissionAsked = "settings.permissionAsk"
        static let muted = "settings.muted"
        static let onboardingDone = "settings.onboardingDone"
        static let routineDone = "settings.routineDone"
        static let painFocus = "settings.painFocus"
    }

    init() {
        let d = UserDefaults.standard
        environment = WorkEnvironment(rawValue: d.string(forKey: Keys.environment) ?? "") ?? .office
        calendarWriteEnabled = d.bool(forKey: Keys.calendarWrite)
        calendarPermissionRequested = d.bool(forKey: Keys.permissionAsked)
        encouragementsMuted = d.bool(forKey: Keys.muted)
        hasCompletedOnboarding = d.bool(forKey: Keys.onboardingDone)
        hasCompletedRoutine = d.bool(forKey: Keys.routineDone)
        painFocus = PainFocus(rawValue: d.string(forKey: Keys.painFocus) ?? "")
    }

    func persist() {
        let d = UserDefaults.standard
        d.set(environment.rawValue, forKey: Keys.environment)
        d.set(calendarWriteEnabled, forKey: Keys.calendarWrite)
        d.set(calendarPermissionRequested, forKey: Keys.permissionAsked)
        d.set(encouragementsMuted, forKey: Keys.muted)
        d.set(hasCompletedOnboarding, forKey: Keys.onboardingDone)
        d.set(hasCompletedRoutine, forKey: Keys.routineDone)
        d.set(painFocus?.rawValue, forKey: Keys.painFocus)
    }
}