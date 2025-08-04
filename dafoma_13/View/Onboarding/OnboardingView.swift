import SwiftUI

struct OnboardingView: View {
    @ObservedObject var appViewModel: AppViewModel
    @State private var currentPage = 0
    @State private var showingGetStarted = false
    
    private let onboardingSteps = [
        OnboardingStep(
            title: "Welcome to Palette Navigator",
            description: "Discover a new way to organize your life with vibrant colors and intuitive design",
            imageName: "paintpalette.fill",
            color: ColorPalette.primaryBackground
        ),
        OnboardingStep(
            title: "Color Coordinator",
            description: "Organize tasks and projects with our unique color-coded system for maximum productivity",
            imageName: "checklist",
            color: ColorPalette.secondaryBackground
        ),
        OnboardingStep(
            title: "Entertainment Hub",
            description: "Explore and curate media content tailored to your preferences and creative palette",
            imageName: "tv.fill",
            color: ColorPalette.accentBackground
        ),
        OnboardingStep(
            title: "Educational Insights",
            description: "Learn and grow with interactive modules designed around our beautiful color system",
            imageName: "book.fill",
            color: ColorPalette.success
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    currentStep.color.opacity(0.8),
                    currentStep.color.opacity(0.4),
                    ColorPalette.surface
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingSteps.count, id: \.self) { index in
                        OnboardingPageView(step: onboardingSteps[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.paletteEaseInOut, value: currentPage)
                
                // Page Indicators
                pageIndicatorsView
                
                // Navigation Buttons
                navigationButtonsView
                
                Spacer(minLength: 50)
            }
        }
        .onChange(of: currentPage) { _ in
            HapticFeedback.selection()
        }
    }
    
    private var currentStep: OnboardingStep {
        onboardingSteps[currentPage]
    }
    
    private var headerView: some View {
        HStack {
            Text("Palette Navigator")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            Spacer()
            
            if currentPage < onboardingSteps.count - 1 {
                Button("Skip") {
                    withAnimation(.paletteSpring) {
                        currentPage = onboardingSteps.count - 1
                    }
                }
                .foregroundColor(.white.opacity(0.8))
                .font(.system(size: 16, weight: .medium))
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
    }
    
    private var pageIndicatorsView: some View {
        HStack(spacing: 12) {
            ForEach(0..<onboardingSteps.count, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    .animation(.paletteSpring, value: currentPage)
            }
        }
        .padding(.vertical, 30)
    }
    
    private var navigationButtonsView: some View {
        HStack(spacing: 20) {
            if currentPage > 0 {
                Button(action: previousPage) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .secondaryButtonStyle()
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
            Spacer()
            
            if currentPage < onboardingSteps.count - 1 {
                Button(action: nextPage) {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .primaryButtonStyle()
                }
            } else {
                Button(action: completeOnboarding) {
                    HStack {
                        Text("Get Started")
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .accentButtonStyle()
                    .scaleEffect(showingGetStarted ? 1.1 : 1.0)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        showingGetStarted = true
                    }
                }
            }
        }
        .padding(.horizontal, 30)
    }
    
    private func nextPage() {
        withAnimation(.paletteSpring) {
            currentPage = min(currentPage + 1, onboardingSteps.count - 1)
        }
    }
    
    private func previousPage() {
        withAnimation(.paletteSpring) {
            currentPage = max(currentPage - 1, 0)
        }
    }
    
    private func completeOnboarding() {
        HapticFeedback.notification(.success)
        withAnimation(.paletteSpring) {
            appViewModel.completeOnboarding()
        }
    }
}

struct OnboardingPageView: View {
    let step: OnboardingStep
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                
                Image(systemName: step.imageName)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .onAppear {
                isAnimating = true
            }
            
            // Title
            Text(step.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                .padding(.horizontal, 30)
            
            // Description
            Text(step.description)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(appViewModel: AppViewModel())
} 