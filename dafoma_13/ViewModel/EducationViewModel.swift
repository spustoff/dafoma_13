import SwiftUI
import Combine

@MainActor
class EducationViewModel: ObservableObject {
    @Published var modules: [EducationalModule] = []
    @Published var selectedDifficulty: EducationalModule.Difficulty? = nil
    @Published var selectedCategory: EducationalModule.EducationCategory? = nil
    @Published var searchText: String = ""
    @Published var currentModule: EducationalModule? = nil
    @Published var currentLesson: Lesson? = nil
    @Published var showingQuiz: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let modulesKey = "savedEducationModules"
    
    init() {
        loadModules()
        setupSampleData()
    }
    
    var filteredModules: [EducationalModule] {
        modules.filter { module in
            let matchesDifficulty = selectedDifficulty == nil || module.difficulty == selectedDifficulty
            let matchesCategory = selectedCategory == nil || module.category == selectedCategory
            let matchesSearch = searchText.isEmpty ||
                module.title.localizedCaseInsensitiveContains(searchText) ||
                module.description.localizedCaseInsensitiveContains(searchText)
            
            return matchesDifficulty && matchesCategory && matchesSearch
        }
    }
    
    var modulesByCategory: [EducationalModule.EducationCategory: [EducationalModule]] {
        Dictionary(grouping: filteredModules) { $0.category }
    }
    
    var completedModulesCount: Int {
        modules.filter { $0.isCompleted }.count
    }
    
    var totalModulesCount: Int {
        modules.count
    }
    
    var overallProgress: Double {
        guard totalModulesCount > 0 else { return 0.0 }
        let totalProgress = modules.reduce(0.0) { $0 + $1.progress }
        return totalProgress / Double(totalModulesCount)
    }
    
    func startModule(_ module: EducationalModule) {
        currentModule = module
        if let firstLesson = module.lessons.first {
            currentLesson = firstLesson
        }
    }
    
    func completeLesson(_ lesson: Lesson) {
        guard var module = currentModule,
              let moduleIndex = modules.firstIndex(where: { $0.id == module.id }),
              let lessonIndex = module.lessons.firstIndex(where: { $0.id == lesson.id }) else { return }
        
        module.lessons[lessonIndex].isCompleted = true
        modules[moduleIndex] = module
        currentModule = module
        
        updateModuleProgress()
        saveModules()
    }
    
    func submitQuizAnswer(questionId: UUID, answer: Int) {
        guard var lesson = currentLesson,
              var quiz = lesson.quiz,
              let questionIndex = quiz.questions.firstIndex(where: { $0.id == questionId }) else { return }
        
        quiz.questions[questionIndex].userAnswer = answer
        
        // Check if quiz is completed
        let allAnswered = quiz.questions.allSatisfy { $0.userAnswer != nil }
        if allAnswered {
            quiz.isCompleted = true
            quiz.score = quiz.questions.reduce(0) { score, question in
                return score + (question.userAnswer == question.correctAnswer ? 1 : 0)
            }
            lesson.quiz = quiz
            lesson.isCompleted = true
            currentLesson = lesson
            
            // Update in module
            updateLessonInModule(lesson)
        }
    }
    
    func nextLesson() {
        guard let module = currentModule,
              let currentLessonId = currentLesson?.id,
              let currentIndex = module.lessons.firstIndex(where: { $0.id == currentLessonId }),
              currentIndex + 1 < module.lessons.count else { return }
        
        currentLesson = module.lessons[currentIndex + 1]
    }
    
    func previousLesson() {
        guard let module = currentModule,
              let currentLessonId = currentLesson?.id,
              let currentIndex = module.lessons.firstIndex(where: { $0.id == currentLessonId }),
              currentIndex > 0 else { return }
        
        currentLesson = module.lessons[currentIndex - 1]
    }
    
    func clearFilters() {
        selectedDifficulty = nil
        selectedCategory = nil
        searchText = ""
    }
    
    private func updateLessonInModule(_ lesson: Lesson) {
        guard var module = currentModule,
              let moduleIndex = modules.firstIndex(where: { $0.id == module.id }),
              let lessonIndex = module.lessons.firstIndex(where: { $0.id == lesson.id }) else { return }
        
        module.lessons[lessonIndex] = lesson
        modules[moduleIndex] = module
        currentModule = module
        
        updateModuleProgress()
        saveModules()
    }
    
    private func updateModuleProgress() {
        guard var module = currentModule,
              let moduleIndex = modules.firstIndex(where: { $0.id == module.id }) else { return }
        
        let completedLessons = module.lessons.filter { $0.isCompleted }.count
        let totalLessons = module.lessons.count
        
        if totalLessons > 0 {
            module.progress = Double(completedLessons) / Double(totalLessons)
            module.isCompleted = module.progress == 1.0
            modules[moduleIndex] = module
            currentModule = module
        }
    }
    
    private func saveModules() {
        if let encoded = try? JSONEncoder().encode(modules) {
            userDefaults.set(encoded, forKey: modulesKey)
        }
    }
    
    private func loadModules() {
        if let data = userDefaults.data(forKey: modulesKey),
           let decodedModules = try? JSONDecoder().decode([EducationalModule].self, from: data) {
            modules = decodedModules
        }
    }
    
    private func setupSampleData() {
        guard modules.isEmpty else { return }
        
        // Create sample quizzes
        let swiftUIQuiz = Quiz(questions: [
            Question(
                text: "What is the primary purpose of SwiftUI?",
                options: ["Database management", "User interface creation", "Network requests", "File storage"],
                correctAnswer: 1,
                explanation: "SwiftUI is Apple's declarative framework for building user interfaces across all Apple platforms."
            ),
            Question(
                text: "Which modifier is used to add padding in SwiftUI?",
                options: [".margin()", ".padding()", ".spacing()", ".offset()"],
                correctAnswer: 1,
                explanation: "The .padding() modifier adds space around a view's content."
            )
        ])
        
        let designQuiz = Quiz(questions: [
            Question(
                text: "What does the color #ae2d27 represent in our palette?",
                options: ["Success color", "Primary background", "Alert color", "Accent color"],
                correctAnswer: 1,
                explanation: "The color #ae2d27 is defined as our primary background color in the ColorPalette."
            )
        ])
        
        // Create sample lessons
        let swiftUILessons = [
            Lesson(
                title: "Introduction to SwiftUI",
                content: "SwiftUI is a revolutionary framework that makes building user interfaces faster and more enjoyable. It uses a declarative syntax that's easy to read and natural to write.",
                duration: 600, // 10 minutes
                quiz: swiftUIQuiz
            ),
            Lesson(
                title: "Views and Modifiers",
                content: "In SwiftUI, views are the building blocks of your interface. Modifiers allow you to customize the appearance and behavior of views.",
                duration: 900 // 15 minutes
            ),
            Lesson(
                title: "State Management",
                content: "SwiftUI provides several property wrappers like @State, @Binding, and @ObservedObject to manage data flow in your app.",
                duration: 1200 // 20 minutes
            )
        ]
        
        let designLessons = [
            Lesson(
                title: "Color Theory Basics",
                content: "Understanding color relationships is fundamental to creating visually appealing designs. Learn about complementary, analogous, and triadic color schemes.",
                duration: 800,
                quiz: designQuiz
            ),
            Lesson(
                title: "Apple Design Guidelines",
                content: "Apple's Human Interface Guidelines provide principles for creating intuitive and beautiful user experiences across all Apple platforms.",
                duration: 1000
            )
        ]
        
        let businessLessons = [
            Lesson(
                title: "Project Management Fundamentals",
                content: "Learn the basics of managing projects effectively, including planning, execution, and monitoring progress.",
                duration: 1500
            ),
            Lesson(
                title: "Team Collaboration",
                content: "Discover strategies for effective team communication and collaboration in modern work environments.",
                duration: 1200
            )
        ]
        
        // Create sample modules
        let sampleModules = [
            EducationalModule(
                title: "SwiftUI Fundamentals",
                description: "Master the basics of Apple's modern UI framework",
                difficulty: .beginner,
                category: .technology,
                lessons: swiftUILessons
            ),
            EducationalModule(
                title: "Design Systems & Color Theory",
                description: "Create cohesive and beautiful user interfaces",
                difficulty: .intermediate,
                category: .design,
                lessons: designLessons
            ),
            EducationalModule(
                title: "Business Operations",
                description: "Essential skills for modern business management",
                difficulty: .beginner,
                category: .business,
                lessons: businessLessons
            ),
            EducationalModule(
                title: "Advanced iOS Development",
                description: "Deep dive into complex iOS app architecture",
                difficulty: .advanced,
                category: .technology,
                lessons: [
                    Lesson(
                        title: "MVVM Architecture",
                        content: "Learn how to implement the Model-View-ViewModel pattern in SwiftUI applications for better code organization and testability.",
                        duration: 1800
                    ),
                    Lesson(
                        title: "Core Data Integration",
                        content: "Integrate Core Data with SwiftUI for persistent data storage and complex data relationships.",
                        duration: 2100
                    )
                ]
            )
        ]
        
        modules = sampleModules
        saveModules()
    }
} 