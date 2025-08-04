import SwiftUI

struct AddTaskView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory = Task.TaskCategory.business
    @State private var selectedPriority = Task.TaskPriority.medium
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorPalette.surface.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Form Fields
                        formFieldsView
                        
                        // Action Buttons
                        actionButtonsView
                    }
                    .padding()
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarStyle()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .foregroundColor(.white)
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(selectedCategory.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(selectedCategory.color)
            }
            
            Text("Create New Task")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.onSurface)
            
            Text("Organize your work with our color-coded system")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var formFieldsView: some View {
        VStack(spacing: 20) {
            // Title Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Task Title *")
                    .font(.headline)
                    .foregroundColor(ColorPalette.onSurface)
                
                TextField("Enter task title", text: $title)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            // Description Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)
                    .foregroundColor(ColorPalette.onSurface)
                
                TextField("Enter task description", text: $description)
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
                            isSelected: selectedCategory == category
                        ) {
                            HapticFeedback.selection()
                            selectedCategory = category
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
                            isSelected: selectedPriority == priority
                        ) {
                            HapticFeedback.selection()
                            selectedPriority = priority
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
                    DatePicker("Select due date", selection: $dueDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .accentColor(selectedCategory.color)
                        .transition(.opacity.combined(with: .slide))
                }
            }
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            Button("Create Task") {
                saveTask()
            }
            .frame(maxWidth: .infinity)
            .primaryButtonStyle()
            .disabled(title.isEmpty)
            
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .frame(maxWidth: .infinity)
            .secondaryButtonStyle()
        }
    }
    
    private func saveTask() {
        guard !title.isEmpty else { return }
        
        let newTask = Task(
            title: title,
            description: description,
            priority: selectedPriority,
            category: selectedCategory,
            dueDate: hasDueDate ? dueDate : nil
        )
        
        HapticFeedback.notification(.success)
        viewModel.addTask(newTask)
        presentationMode.wrappedValue.dismiss()
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorPalette.primaryBackground.opacity(0.3), lineWidth: 1)
            )
    }
}

struct CategorySelectionCard: View {
    let category: Task.TaskCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: categoryIcon)
                        .font(.title2)
                        .foregroundColor(category.color)
                }
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : ColorPalette.onSurface)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? category.color : ColorPalette.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(category.color, lineWidth: isSelected ? 0 : 1)
            )
            .shadow(color: isSelected ? category.color.opacity(0.3) : Color.clear, radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var categoryIcon: String {
        switch category {
        case .business: return "briefcase.fill"
        case .personal: return "person.fill"
        case .creative: return "paintbrush.fill"
        case .education: return "book.fill"
        }
    }
}

struct PrioritySelectionCard: View {
    let priority: Task.TaskPriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Circle()
                    .fill(priority.color)
                    .frame(width: 12, height: 12)
                
                Text(priority.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : ColorPalette.onSurface)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? priority.color : ColorPalette.surface)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(priority.color, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddTaskView(viewModel: TaskViewModel())
} 
