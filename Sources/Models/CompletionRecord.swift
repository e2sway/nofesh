import Foundation
import SwiftData

@Model
final class CompletionRecord {
    var blockID: String
    var exerciseID: String
    var completedAt: Date
    var environment: String

    init(blockID: String, exerciseID: String, completedAt: Date, environment: String) {
        self.blockID = blockID
        self.exerciseID = exerciseID
        self.completedAt = completedAt
        self.environment = environment
    }
}