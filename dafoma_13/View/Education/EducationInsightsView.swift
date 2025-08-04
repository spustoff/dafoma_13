import SwiftUI

struct EducationInsightsView: View {
    @ObservedObject var viewModel: EducationViewModel
    @State private var showingFilters = false
    @State private var selectedModule: EducationalModule?
    
    var body: some View {
        ZStack {
            ColorPalette.surface.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                headerView
                
                // Progress Overview
                progressOverviewView
                
                // Filter Section
                if showingFilters {
                    filterSectionView
                        .transition(.slide)
                }
                
                // Content
                contentView
            }
        }
        .navigationBarStyle()
        .navigationTitle("Educational Insights")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingFilters.toggle() }) {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    
                    Button(action: { viewModel.clearFilters() }) {
                        Label("Clear Filters", systemImage: "xmark.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
        }
        .sheet(item: $selectedModule) { module in
            LearningModuleView(module: module, viewModel: viewModel)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Learning Hub")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Expand your knowledge with interactive lessons")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "graduationcap.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [ColorPalette.success, ColorPalette.success.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var progressOverviewView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Modules",
                    value: "\(viewModel.totalModulesCount)",
                    color: ColorPalette.primaryBackground,
                    icon: "book.fill"
                )
                
                StatCard(
                    title: "Completed",
                    value: "\(viewModel.completedModulesCount)",
                    color: ColorPalette.success,
                    icon: "checkmark.circle.fill"
                )
                
                StatCard(
                    title: "Overall Progress",
                    value: viewModel.overallProgress.asProgressPercentage(),
                    color: ColorPalette.accentBackground,
                    icon: "chart.pie.fill"
                )
                
                ForEach(EducationalModule.EducationCategory.allCases, id: \.self) { category in
                    let count = viewModel.modules.filter { $0.category == category }.count
                    if count > 0 {
                        StatCard(
                            title: category.rawValue,
                            value: "\(count)",
                            color: category.color,
                            icon: categoryIcon(for: category)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private var filterSectionView: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search modules...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "All Categories",
                        isSelected: viewModel.selectedCategory == nil,
                        color: ColorPalette.onSurface
                    ) {
                        viewModel.selectedCategory = nil
                    }
                    
                    ForEach(EducationalModule.EducationCategory.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.rawValue,
                            isSelected: viewModel.selectedCategory == category,
                            color: category.color
                        ) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Difficulty Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "All Levels",
                        isSelected: viewModel.selectedDifficulty == nil,
                        color: ColorPalette.onSurface
                    ) {
                        viewModel.selectedDifficulty = nil
                    }
                    
                    ForEach(EducationalModule.Difficulty.allCases, id: \.self) { difficulty in
                        FilterChip(
                            title: difficulty.rawValue,
                            isSelected: viewModel.selectedDifficulty == difficulty,
                            color: difficulty.color
                        ) {
                            viewModel.selectedDifficulty = difficulty
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(ColorPalette.surface)
    }
    
    private var contentView: some View {
        Group {
            if viewModel.filteredModules.isEmpty {
                emptyStateView
            } else {
                moduleGridView
            }
        }
    }
    
    private var moduleGridView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 16) {
                ForEach(viewModel.filteredModules) { module in
                    EducationModuleCard(module: module) {
                        selectedModule = module
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No modules found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Try adjusting your search criteria or clear filters")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Clear Filters") {
                viewModel.clearFilters()
            }
            .accentButtonStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.surface)
    }
    
    private func categoryIcon(for category: EducationalModule.EducationCategory) -> String {
        switch category {
        case .technology: return "laptopcomputer"
        case .design: return "paintbrush.fill"
        case .business: return "briefcase.fill"
        case .languages: return "globe"
        case .science: return "atom"
        }
    }
}

struct EducationModuleCard: View {
    let module: EducationalModule
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(module.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(ColorPalette.onSurface)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Text(module.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // Category Icon
                    ZStack {
                        Circle()
                            .fill(module.category.color.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: categoryIcon(for: module.category))
                            .font(.title2)
                            .foregroundColor(module.category.color)
                    }
                }
                
                // Progress Bar
                VStack(spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(module.progress.asProgressPercentage())
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(module.category.color)
                    }
                    
                    ProgressView(value: module.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: module.category.color))
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
                
                // Tags and Info
                HStack {
                    // Difficulty Badge
                    Text(module.difficulty.rawValue)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(module.difficulty.color)
                        .cornerRadius(4)
                    
                    // Category Badge
                    Text(module.category.rawValue)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(module.category.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(module.category.color.opacity(0.2))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Lesson Count
                    HStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                            .font(.caption)
                            .foregroundColor(module.category.color)
                        
                        Text("\(module.lessons.count) lessons")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Action Button
                HStack {
                    if module.isCompleted {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(ColorPalette.success)
                    } else if module.progress > 0 {
                        Label("Continue Learning", systemImage: "play.fill")
                            .font(.subheadline)
                            .foregroundColor(module.category.color)
                    } else {
                        Label("Start Learning", systemImage: "play.fill")
                            .font(.subheadline)
                            .foregroundColor(module.category.color)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func categoryIcon(for category: EducationalModule.EducationCategory) -> String {
        switch category {
        case .technology: return "laptopcomputer"
        case .design: return "paintbrush.fill"
        case .business: return "briefcase.fill"
        case .languages: return "globe"
        case .science: return "atom"
        }
    }
}

#Preview {
    NavigationView {
        EducationInsightsView(viewModel: EducationViewModel())
    }
} 
