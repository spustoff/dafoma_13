import SwiftUI

struct LearningModuleView: View {
    let module: EducationalModule
    @ObservedObject var viewModel: EducationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedLesson: Lesson?
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        module.category.color.opacity(0.1),
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
                        
                        // Progress Section
                        progressSectionView
                        
                        // Lessons List
                        lessonsListView
                    }
                    .padding()
                }
            }
            .navigationTitle("Learning Module")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarStyle()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !module.lessons.isEmpty {
                        Button("Start Learning") {
                            startModule()
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonView(lesson: lesson, module: module, viewModel: viewModel)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 20) {
            // Module Icon
            ZStack {
                Circle()
                    .fill(module.category.color.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: categoryIcon)
                    .font(.system(size: 60))
                    .foregroundColor(module.category.color)
            }
            
            // Module Info
            VStack(spacing: 12) {
                Text(module.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorPalette.onSurface)
                    .multilineTextAlignment(.center)
                
                Text(module.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Tags
                HStack(spacing: 12) {
                    // Difficulty Badge
                    Text(module.difficulty.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(module.difficulty.color)
                        .cornerRadius(8)
                    
                    // Category Badge
                    Text(module.category.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(module.category.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(module.category.color.opacity(0.2))
                        .cornerRadius(8)
                    
                    // Lesson Count
                    Text("\(module.lessons.count) lessons")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private var progressSectionView: some View {
        VStack(spacing: 16) {
            // Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("Overall Progress")
                        .font(.headline)
                        .foregroundColor(ColorPalette.onSurface)
                    
                    Spacer()
                    
                    Text(module.progress.asProgressPercentage())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(module.category.color)
                }
                
                ProgressView(value: module.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: module.category.color))
                    .background(Color(.systemGray5))
                    .cornerRadius(6)
                    .frame(height: 12)
            }
            
            // Stats
            HStack(spacing: 20) {
                StatCard(
                    title: "Total Lessons",
                    value: "\(module.lessons.count)",
                    color: module.category.color,
                    icon: "play.circle"
                )
                
                StatCard(
                    title: "Completed",
                    value: "\(completedLessonsCount)",
                    color: ColorPalette.success,
                    icon: "checkmark.circle.fill"
                )
                
                StatCard(
                    title: "Time Est.",
                    value: totalDuration.asFormattedDuration(),
                    color: ColorPalette.secondaryBackground,
                    icon: "clock"
                )
            }
        }
        .padding()
        .cardStyle()
    }
    
    private var lessonsListView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lessons")
                .font(.headline)
                .foregroundColor(ColorPalette.onSurface)
            
            ForEach(Array(module.lessons.enumerated()), id: \.element.id) { index, lesson in
                LessonRowView(
                    lesson: lesson,
                    lessonNumber: index + 1,
                    module: module,
                    isUnlocked: index == 0 || (index > 0 && module.lessons[index - 1].isCompleted)
                ) {
                    selectedLesson = lesson
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private var categoryIcon: String {
        switch module.category {
        case .technology: return "laptopcomputer"
        case .design: return "paintbrush.fill"
        case .business: return "briefcase.fill"
        case .languages: return "globe"
        case .science: return "atom"
        }
    }
    
    private var completedLessonsCount: Int {
        module.lessons.filter { $0.isCompleted }.count
    }
    
    private var totalDuration: TimeInterval {
        module.lessons.reduce(0) { $0 + $1.duration }
    }
    
    private func startModule() {
        if let firstLesson = module.lessons.first {
            selectedLesson = firstLesson
        }
    }
}

struct LessonRowView: View {
    let lesson: Lesson
    let lessonNumber: Int
    let module: EducationalModule
    let isUnlocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Lesson Number
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    if lesson.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .foregroundColor(ColorPalette.success)
                    } else if isUnlocked {
                        Text("\(lessonNumber)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(module.category.color)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
                
                // Lesson Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isUnlocked ? ColorPalette.onSurface : .gray)
                        .lineLimit(2)
                    
                    HStack {
                        // Duration
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(lesson.duration.asFormattedDuration())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Quiz indicator
                        if lesson.quiz != nil {
                            HStack(spacing: 4) {
                                Image(systemName: "questionmark.circle")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("Quiz")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Status Icon
                if lesson.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(ColorPalette.success)
                } else if isUnlocked {
                    Image(systemName: "play.circle")
                        .font(.title3)
                        .foregroundColor(module.category.color)
                } else {
                    Image(systemName: "lock.circle")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(isUnlocked ? ColorPalette.surface : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(statusColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isUnlocked)
    }
    
    private var statusColor: Color {
        if lesson.isCompleted {
            return ColorPalette.success
        } else if isUnlocked {
            return module.category.color
        } else {
            return .gray
        }
    }
}

#Preview {
    LearningModuleView(
        module: EducationalModule(
            title: "SwiftUI Fundamentals",
            description: "Master the basics of Apple's modern UI framework",
            difficulty: .beginner,
            category: .technology,
            lessons: [
                Lesson(
                    title: "Introduction to SwiftUI",
                    content: "Learn the basics",
                    duration: 600
                ),
                Lesson(
                    title: "Views and Modifiers",
                    content: "Understanding UI components",
                    duration: 900
                )
            ]
        ),
        viewModel: EducationViewModel()
    )
} 
