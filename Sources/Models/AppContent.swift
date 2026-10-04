import Foundation
import Observation

@Observable
final class AppContent {
    let library: ContentLibrary

    init() {
        library = ContentLoader.load()
    }
}