import SwiftUI
import Combine

@MainActor
class AppViewModel: ObservableObject {
    @Published var appState: AppState = .onboarding
    @Published var selectedTab: MainTab = .coordinator
    @Published var hasCompletedOnboarding: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let onboardingKey = "hasCompletedOnboarding"
    
    init() {
        loadOnboardingStatus()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        appState = .main
        saveOnboardingStatus()
    }
    
    func selectTab(_ tab: MainTab) {
        selectedTab = tab
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        appState = .onboarding
        saveOnboardingStatus()
    }
    
    private func loadOnboardingStatus() {
        hasCompletedOnboarding = userDefaults.bool(forKey: onboardingKey)
        appState = hasCompletedOnboarding ? .main : .onboarding
    }
    
    private func saveOnboardingStatus() {
        userDefaults.set(hasCompletedOnboarding, forKey: onboardingKey)
    }
} 