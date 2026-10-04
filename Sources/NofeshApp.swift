import SwiftUI
import SwiftData

@main
struct NofeshApp: App {
    let container: ModelContainer
    @State private var content = AppContent()
    @State private var settings = AppSettings()

    init() {
        do {
            container = try ModelContainer(for: CompletionRecord.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(content)
                .environment(settings)
                .modelContainer(container)
        }
    }
}