import Foundation

enum Position: String, Codable, CaseIterable, Identifiable {
    case seated
    case standing
    case either

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .seated: return "Seated"
        case .standing: return "Standing"
        case .either: return "Seated or Standing"
        }
    }
}

enum ExerciseVisual: Codable, Equatable {
    /// A pre-rendered looping video clip (bundled `.mp4` or remote URL).
    case video(assetName: String?)
    /// A looping skeletal animation from a bundled `.usdz`.
    case model3D(assetName: String?)
    /// A built-in animated avatar pose (used until production clips exist).
    case avatar(pose: String)
}

struct ExerciseSegment: Codable, Identifiable, Equatable {
    var id: String { UUID().uuidString }
    var title: String
    var duration: Int
    var cue: String
    var mirrored: Bool?

    func isMirrored(_ defaultValue: Bool) -> Bool {
        mirrored ?? defaultValue
    }
}

struct Exercise: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var position: Position
    var duration: Int
    var whyItHelps: String
    var visual: ExerciseVisual
    var segments: [ExerciseSegment]?
}

struct RoutineBlock: Codable, Identifiable, Equatable {
    var id: String
    var title: String
    var subtitle: String
    var focus: String
    var suggestedTime: String
    var position: Position
    var exercises: [Exercise]

    var totalDuration: Int {
        exercises.reduce(0) { $0 + $1.duration }
    }
}

struct ContentLibrary: Codable {
    var blocks: [RoutineBlock]
}