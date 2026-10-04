import SwiftUI
import UserNotifications

struct RootView: View {
    @Environment(AppContent.self) private var content
    @Environment(AppSettings.self) private var settings

    @State private var pendingBlock: RoutineBlock?

    var body: some View {
        Group {
            if settings.hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView()
            }
        }
        .fullScreenCover(item: $pendingBlock) { block in
            PlayerView(block: block)
        }
        .onAppear {
            NotificationService.setDelegate { blockID in
                if let block = content.library.blocks.first(where: { $0.id == blockID }) {
                    pendingBlock = block
                }
            }
        }
    }
}