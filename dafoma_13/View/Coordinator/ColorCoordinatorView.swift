import SwiftUI

struct ColorCoordinatorView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var showingAddTask = false
    @State private var showingFilters = false
    
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
                
                // Task List
                taskListView
            }
        }
        .navigationBarStyle()
        .navigationTitle("Color Coordinator")
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
                    
                    Button(action: { showingAddTask = true }) {
                        Label("Add Task", systemImage: "plus.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(viewModel: viewModel)
        }
        .onChange(of: viewModel.tasks) { _ in
            if viewModel.tasks.isEmpty {
                withAnimation(.paletteSpring) {
                    showingFilters = false
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome Back!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Let's organize your tasks")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [ColorPalette.primaryBackground, ColorPalette.primaryBackground.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var progressOverviewView: some View {
        Group {
            if DeviceInfo.isPad {
                // iPad: Grid layout for stats with more space
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: 3),
                    spacing: DeviceInfo.adaptiveSpacing
                ) {
                    // Total Tasks
                    StatCard(
                        title: "Total Tasks",
                        value: "\(viewModel.totalTasksCount)",
                        color: ColorPalette.secondaryBackground,
                        icon: "checklist"
                    )
                    
                    // Completed
                    StatCard(
                        title: "Completed",
                        value: "\(viewModel.completedTasksCount)",
                        color: ColorPalette.success,
                        icon: "checkmark.circle.fill"
                    )
                    
                    // Progress
                    StatCard(
                        title: "Progress",
                        value: viewModel.completionProgress.asProgressPercentage(),
                        color: ColorPalette.accentBackground,
                        icon: "chart.pie.fill"
                    )
                }
                .padding(DeviceInfo.adaptivePadding)
            } else {
                // iPhone: Horizontal layout
                HStack(spacing: 20) {
                    // Total Tasks
                    StatCard(
                        title: "Total Tasks",
                        value: "\(viewModel.totalTasksCount)",
                        color: ColorPalette.secondaryBackground,
                        icon: "checklist"
                    )
                    
                    // Completed
                    StatCard(
                        title: "Completed",
                        value: "\(viewModel.completedTasksCount)",
                        color: ColorPalette.success,
                        icon: "checkmark.circle.fill"
                    )
                    
                    // Progress
                    StatCard(
                        title: "Progress",
                        value: viewModel.completionProgress.asProgressPercentage(),
                        color: ColorPalette.accentBackground,
                        icon: "chart.pie.fill"
                    )
                }
                .padding()
            }
        }
    }
    
    private var filterSectionView: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search tasks...", text: $viewModel.searchText)
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
                    
                    ForEach(Task.TaskCategory.allCases, id: \.self) { category in
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
            
            // Priority Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "All Priorities",
                        isSelected: viewModel.selectedPriority == nil,
                        color: ColorPalette.onSurface
                    ) {
                        viewModel.selectedPriority = nil
                    }
                    
                    ForEach(Task.TaskPriority.allCases, id: \.self) { priority in
                        FilterChip(
                            title: priority.rawValue,
                            isSelected: viewModel.selectedPriority == priority,
                            color: priority.color
                        ) {
                            viewModel.selectedPriority = priority
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(ColorPalette.surface)
    }
    
    private var taskListView: some View {
        Group {
            if viewModel.filteredTasks.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(Array(viewModel.tasksByCategory.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { category in
                        Section(header: CategoryHeaderView(category: category)) {
                            ForEach(viewModel.tasksByCategory[category] ?? []) { task in
                                TaskRowView(task: task, viewModel: viewModel)
                                    .listRowInsets(EdgeInsets(
                                        top: DeviceInfo.isPad ? 12 : 8,
                                        leading: DeviceInfo.adaptivePadding,
                                        bottom: DeviceInfo.isPad ? 12 : 8,
                                        trailing: DeviceInfo.adaptivePadding
                                    ))
                                    .listRowBackground(Color.clear)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    // Add refresh functionality if needed
                    HapticFeedback.impact(.light)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No tasks found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Create your first task to get started with organizing your work")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Add Task") {
                showingAddTask = true
            }
            .accentButtonStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.surface)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.onSurface)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticFeedback.selection()
            action()
        }) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : color.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryHeaderView: View {
    let category: Task.TaskCategory
    
    var body: some View {
        HStack {
            Circle()
                .fill(category.color)
                .frame(width: 12, height: 12)
            
            Text(category.rawValue)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(ColorPalette.onSurface)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct TaskRowView: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    @State private var showingDetails = false
    
    var body: some View {
        Button(action: { showingDetails = true }) {
            HStack(spacing: 12) {
                // Completion Button
                Button(action: {
                    HapticFeedback.impact(.light)
                    withAnimation(.paletteSpring) {
                        viewModel.toggleTaskCompletion(task)
                    }
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(task.isCompleted ? ColorPalette.success : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(task.isCompleted ? .gray : ColorPalette.onSurface)
                        .strikethrough(task.isCompleted)
                    
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        // Priority Badge
                        Text(task.priority.rawValue)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(task.priority.color)
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        // Due Date
                        if let dueDate = task.dueDate {
                            Text(dueDate.dueDateDisplay())
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(DeviceInfo.isPad ? .body : .caption)
                    .foregroundColor(.gray)
            }
            .padding(DeviceInfo.isPad ? 20 : 16)
            .frame(minHeight: DeviceInfo.minTouchTargetSize)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetails) {
            TaskDetailView(task: task, viewModel: viewModel)
        }
    }
}

#Preview {
    NavigationView {
        ColorCoordinatorView(viewModel: TaskViewModel())
    }
} 
