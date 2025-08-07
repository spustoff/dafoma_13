import SwiftUI

struct MainTabView: View {
    @ObservedObject var appViewModel: AppViewModel
    @StateObject private var taskViewModel = TaskViewModel()
    @StateObject private var entertainmentViewModel = EntertainmentViewModel()
    @StateObject private var educationViewModel = EducationViewModel()
    
    var body: some View {
        TabView(selection: $appViewModel.selectedTab) {
            // Color Coordinator Tab
            NavigationView {
                ColorCoordinatorView(viewModel: taskViewModel)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: MainTab.coordinator.icon)
                Text(MainTab.coordinator.title)
            }
            .tag(MainTab.coordinator)
            
            // Entertainment Tab
            NavigationView {
                EntertainmentHubView(viewModel: entertainmentViewModel)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: MainTab.entertainment.icon)
                Text(MainTab.entertainment.title)
            }
            .tag(MainTab.entertainment)
            
            // Education Tab
            NavigationView {
                EducationInsightsView(viewModel: educationViewModel)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: MainTab.education.icon)
                Text(MainTab.education.title)
            }
            .tag(MainTab.education)
        }
        .accentColor(appViewModel.selectedTab.color)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            // Selected item color
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(appViewModel.selectedTab.color)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(appViewModel.selectedTab.color)
            ]
            
            // Normal item color
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemGray
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .onChange(of: appViewModel.selectedTab) { _ in
            HapticFeedback.selection()
        }
    }
}

#Preview {
    MainTabView(appViewModel: AppViewModel())
} 