//
//  ContentView.swift
//  dafoma_13
//
//  Created by Вячеслав on 8/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some View {
        ZStack {
            switch appViewModel.appState {
            case .onboarding:
                OnboardingView(appViewModel: appViewModel)
                    .transition(.opacity.combined(with: .scale))
            case .main:
                MainTabView(appViewModel: appViewModel)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.paletteSpring, value: appViewModel.appState)
    }
}

#Preview {
    ContentView()
}
