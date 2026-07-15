import SwiftUI

class AppState: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var needsOnboarding: Bool = false
    @Published var onboardingStep: Int = 0
}
