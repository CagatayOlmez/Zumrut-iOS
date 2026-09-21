import SwiftData
import SwiftUI

@main
struct ZumrutApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                RootTabView()
            } else {
                OnboardingView()
            }
        }
        .modelContainer(for: [
            PrayerRecord.self, FastingRecord.self, DhikrCount.self, CustomDua.self,
            InfoCardReadRecord.self, CommunityEvent.self, Donation.self,
        ])
    }
}
