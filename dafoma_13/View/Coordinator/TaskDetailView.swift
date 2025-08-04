import SwiftUI

struct TaskDetailView: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedDescription: String
    @State private var editedCategory: Task.TaskCategory
    @State private var editedPriority: Task.TaskPriority
    @State private var editedDueDate: Date
    @State private var hasDueDate: Bool
    @State private var showingDeleteAlert = false
    
    init(task: Task, viewModel: TaskViewModel) {
        self.task = task
        self.viewModel = viewModel
        self._editedTitle = State(initialValue: task.title)
        self._editedDescription = State(initialValue: task.description)
        self._editedCategory = State(initialValue: task.category)
        self._editedPriority = State(initialValue: task.priority)
        self._editedDueDate = State(initialValue: task.dueDate ?? Date())
        self._hasDueDate = State(initialValue: task.dueDate != nil)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        task.category.color.opacity(0.1),
                        ColorPalette.surface
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Content
                        if isEditing {
                            editingView
                        } else {
                            detailView
                        }
                        
                        // Action Buttons
                        actionButtonsView
                    }
                    .padding()
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarStyle()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "Cancel" : "Close") {
                        if isEditing {
                            cancelEditing()
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Save") {
                            saveChanges()
                        }
                        .foregroundColor(.white)
                        .disabled(editedTitle.isEmpty)
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteTask()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Status Indicator
            ZStack {
                Circle()
                    .fill(task.category.color.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 50))
                    .foregroundColor(task.isCompleted ? ColorPalette.success : task.category.color)
            }
            
            // Completion Toggle
            if !isEditing {
                Button(action: {
                    HapticFeedback.impact(.medium)
                    withAnimation(.paletteSpring) {
                        viewModel.toggleTaskCompletion(task)
                    }
                }) {
                    HStack {
                        Image(systemName: task.isCompleted ? "arrow.uturn.left.circle" : "checkmark.circle")
                        Text(task.isCompleted ? "Mark Incomplete" : "Mark Complete")
                    }
                    .font(.headline)
                    .foregroundColor(task.isCompleted ? ColorPalette.alert : ColorPalette.success)
                }
            }
        }
    }
    
    private var detailView: some View {
        VStack(spacing: 20) {
            // Title & Description
            VStack(alignment: .leading, spacing: 12) {
                Text(task.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorPalette.onSurface)
                    .strikethrough(task.isCompleted)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .cardStyle()
            
            // Properties
            VStack(spacing: 16) {
                // Category
                PropertyRow(
                    title: "Category",
                    value: task.category.rawValue,
                    color: task.category.color,
                    icon: "folder.fill"
                )
                
                // Priority
                PropertyRow(
                    title: "Priority",
                    value: task.priority.rawValue,
                    color: task.priority.color,
                    icon: "exclamationmark.triangle.fill"
                )
                
                // Created Date
                PropertyRow(
                    title: "Created",
                    value: task.createdDate.timeAgoDisplay(),
                    color: ColorPalette.secondaryBackground,
                    icon: "calendar.badge.plus"
                )
                
                // Due Date
                if let dueDate = task.dueDate {
                    PropertyRow(
                        title: "Due Date",
                        value: dueDate.dueDateDisplay(),
                        color: ColorPalette.alert,
                        icon: "calendar.badge.exclamationmark"
                    )
                }
            }
            .padding()
            .cardStyle()
        }
    }
    
    private var editingView: some View {
        VStack(spacing: 20) {
            // Title Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Task Title *")
                    .font(.headline)
                    .foregroundColor(ColorPalette.onSurface)
                
                TextField("Enter task title", text: $editedTitle)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            // Description Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)
                    .foregroundColor(ColorPalette.onSurface)
                
                TextField("Enter task description", text: $editedDescription)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            // Category Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Category")
                    .font(.headline)
                    .foregroundColor(ColorPalette.onSurface)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(Task.TaskCategory.allCases, id: \.self) { category in
                        CategorySelectionCard(
                            category: category,
                            isSelected: editedCategory == category
                        ) {
                            HapticFeedback.selection()
                            editedCategory = category
                        }
                    }
                }
            }
            
            // Priority Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Priority")
                    .font(.headline)
                    .foregroundColor(ColorPalette.onSurface)
                
                HStack(spacing: 12) {
                    ForEach(Task.TaskPriority.allCases, id: \.self) { priority in
                        PrioritySelectionCard(
                            priority: priority,
                            isSelected: editedPriority == priority
                        ) {
                            HapticFeedback.selection()
                            editedPriority = priority
                        }
                    }
                }
            }
            
            // Due Date Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Due Date")
                        .font(.headline)
                        .foregroundColor(ColorPalette.onSurface)
                    
                    Spacer()
                    
                    Toggle("", isOn: $hasDueDate)
                        .labelsHidden()
                }
                
                if hasDueDate {
                    DatePicker("Select due date", selection: $editedDueDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .accentColor(editedCategory.color)
                        .transition(.opacity.combined(with: .slide))
                }
            }
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            if !isEditing {
                Button("Edit Task") {
                    withAnimation(.paletteEaseInOut) {
                        isEditing = true
                    }
                }
                .frame(maxWidth: .infinity)
                .accentButtonStyle()
                
                Button("Delete Task") {
                    showingDeleteAlert = true
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(ColorPalette.destructive)
                .cornerRadius(8)
                .shadow(color: ColorPalette.destructive.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    private func cancelEditing() {
        editedTitle = task.title
        editedDescription = task.description
        editedCategory = task.category
        editedPriority = task.priority
        editedDueDate = task.dueDate ?? Date()
        hasDueDate = task.dueDate != nil
        
        withAnimation(.paletteEaseInOut) {
            isEditing = false
        }
    }
    
    private func saveChanges() {
        guard !editedTitle.isEmpty else { return }
        
        var updatedTask = task
        updatedTask.title = editedTitle
        updatedTask.description = editedDescription
        updatedTask.category = editedCategory
        updatedTask.priority = editedPriority
        updatedTask.dueDate = hasDueDate ? editedDueDate : nil
        
        HapticFeedback.notification(.success)
        viewModel.updateTask(updatedTask)
        
        withAnimation(.paletteEaseInOut) {
            isEditing = false
        }
    }
    
    private func deleteTask() {
        HapticFeedback.notification(.warning)
        viewModel.deleteTask(task)
        presentationMode.wrappedValue.dismiss()
    }
}

struct PropertyRow: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(ColorPalette.onSurface)
            }
            
            Spacer()
        }
    }
}

#Preview {
    TaskDetailView(
        task: Task(
            title: "Sample Task",
            description: "This is a sample task description",
            priority: .high,
            category: .business,
            dueDate: Date()
        ),
        viewModel: TaskViewModel()
    )
} 
