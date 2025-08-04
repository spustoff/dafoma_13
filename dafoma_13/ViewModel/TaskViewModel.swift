import SwiftUI
import Combine

@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var selectedCategory: Task.TaskCategory? = nil
    @Published var selectedPriority: Task.TaskPriority? = nil
    @Published var searchText: String = ""
    @Published var showingAddTask: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "savedTasks"
    
    init() {
        loadTasks()
        setupSampleData()
    }
    
    var filteredTasks: [Task] {
        tasks.filter { task in
            let matchesCategory = selectedCategory == nil || task.category == selectedCategory
            let matchesPriority = selectedPriority == nil || task.priority == selectedPriority
            let matchesSearch = searchText.isEmpty || 
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText)
            
            return matchesCategory && matchesPriority && matchesSearch
        }
    }
    
    var tasksByCategory: [Task.TaskCategory: [Task]] {
        Dictionary(grouping: filteredTasks) { $0.category }
    }
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var totalTasksCount: Int {
        tasks.count
    }
    
    var completionProgress: Double {
        guard totalTasksCount > 0 else { return 0.0 }
        return Double(completedTasksCount) / Double(totalTasksCount)
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    func clearFilters() {
        selectedCategory = nil
        selectedPriority = nil
        searchText = ""
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            userDefaults.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = userDefaults.data(forKey: tasksKey),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decodedTasks
        }
    }
    
    private func setupSampleData() {
        guard tasks.isEmpty else { return }
        
        let sampleTasks = [
            Task(
                title: "Design App Mockups", 
                description: "Create wireframes and mockups for the new mobile app",
                priority: .high,
                category: .business,
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
            ),
            Task(
                title: "Learn SwiftUI Animations",
                description: "Complete online course on advanced SwiftUI animations",
                priority: .medium,
                category: .education,
                dueDate: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())
            ),
            Task(
                title: "Organize Color Palette",
                description: "Finalize brand colors and create style guide",
                priority: .high,
                category: .creative,
                dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())
            ),
            Task(
                title: "Team Meeting Prep",
                description: "Prepare presentation for quarterly review",
                priority: .medium,
                category: .business,
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())
            )
        ]
        
        tasks = sampleTasks
        saveTasks()
    }
} 
