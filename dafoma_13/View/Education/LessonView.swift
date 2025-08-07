import SwiftUI

struct LessonView: View {
    let lesson: Lesson
    let module: EducationalModule
    @ObservedObject var viewModel: EducationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingQuiz = false
    @State private var currentQuizQuestion = 0
    @State private var selectedAnswers: [Int?] = []
    @State private var showingResults = false
    
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
                
                if showingQuiz {
                    quizView
                } else {
                    lessonContentView
                }
            }
            .navigationTitle(lesson.title)
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
                    if showingQuiz {
                        Button("Exit Quiz") {
                            exitQuiz()
                        }
                        .foregroundColor(.white)
                    } else if !lesson.isCompleted {
                        Button("Complete") {
                            completeLesson()
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            setupQuiz()
        }
    }
    
    private var lessonContentView: some View {
        ScrollView {
            HStack(spacing: 0) {
                if DeviceInfo.isPad {
                    // iPad: Side-by-side layout
                    VStack(spacing: DeviceInfo.adaptiveSpacing) {
                        lessonHeaderView
                        lessonActionButtonsView
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.trailing, DeviceInfo.adaptiveSpacing)
                    
                    VStack(spacing: DeviceInfo.adaptiveSpacing) {
                        lessonContentSectionView
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    // iPhone: Vertical layout
                    VStack(spacing: 24) {
                        lessonHeaderView
                        lessonContentSectionView
                        lessonActionButtonsView
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(DeviceInfo.adaptivePadding)
        }
    }
    
    private var lessonHeaderView: some View {
        VStack(spacing: 16) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(module.category.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : "play.circle")
                    .font(.system(size: 40))
                    .foregroundColor(lesson.isCompleted ? ColorPalette.success : module.category.color)
            }
            
            VStack(spacing: 8) {
                Text(lesson.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorPalette.onSurface)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    // Duration
                    Label(lesson.duration.asFormattedDuration(), systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Quiz indicator
                    if lesson.quiz != nil {
                        Label("Quiz included", systemImage: "questionmark.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Status
                    if lesson.isCompleted {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(ColorPalette.success)
                    }
                }
            }
        }
    }
    
    private var lessonContentSectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lesson Content")
                .font(.headline)
                .foregroundColor(ColorPalette.onSurface)
            
            Text(lesson.content)
                .font(.body)
                .foregroundColor(ColorPalette.onSurface)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
    }
    
    private var lessonActionButtonsView: some View {
        VStack(spacing: 16) {
            if let quiz = lesson.quiz, !quiz.isCompleted {
                Button("Take Quiz") {
                    startQuiz()
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(module.category.color)
                .cornerRadius(8)
                .shadow(color: module.category.color.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            
            if !lesson.isCompleted {
                Button("Mark as Complete") {
                    completeLesson()
                }
                .frame(maxWidth: .infinity)
                .accentButtonStyle()
            }
            
            // Navigation Buttons
            HStack(spacing: 16) {
                if canNavigateToPrevious {
                    Button("Previous Lesson") {
                        navigateToPrevious()
                    }
                    .secondaryButtonStyle()
                }
                
                if canNavigateToNext {
                    Button("Next Lesson") {
                        navigateToNext()
                    }
                    .primaryButtonStyle()
                }
            }
        }
    }
    
    private var quizView: some View {
        VStack(spacing: 0) {
            // Quiz Header
            quizHeaderView
            
            // Quiz Content
            if showingResults {
                quizResultsView
            } else {
                quizQuestionView
            }
        }
    }
    
    private var quizHeaderView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Quiz")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if !showingResults {
                    Text("\(currentQuizQuestion + 1) of \(lesson.quiz?.questions.count ?? 0)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            if !showingResults {
                ProgressView(value: Double(currentQuizQuestion + 1), total: Double(lesson.quiz?.questions.count ?? 1))
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(module.category.color)
    }
    
    private var quizQuestionView: some View {
        ScrollView {
            if DeviceInfo.isPad {
                // iPad: Wider layout with better spacing
                VStack(spacing: DeviceInfo.adaptiveSpacing) {
                    if let quiz = lesson.quiz,
                       currentQuizQuestion < quiz.questions.count {
                        let question = quiz.questions[currentQuizQuestion]
                        
                        HStack(spacing: DeviceInfo.adaptiveSpacing) {
                            // Question Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Question \(currentQuizQuestion + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(question.text)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(ColorPalette.onSurface)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(DeviceInfo.adaptivePadding)
                            .cardStyle()
                            
                            // Answer Options Section
                            VStack(spacing: 16) {
                                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                                    QuizAnswerOption(
                                        text: option,
                                        index: index,
                                        isSelected: selectedAnswers[safe: currentQuizQuestion] == index,
                                        color: module.category.color
                                    ) {
                                        selectAnswer(index)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Navigation
                        HStack(spacing: DeviceInfo.adaptiveSpacing) {
                            if currentQuizQuestion > 0 {
                                Button("Previous") {
                                    previousQuestion()
                                }
                                .secondaryButtonStyle()
                            }
                            
                            Spacer()
                            
                            if currentQuizQuestion < quiz.questions.count - 1 {
                                Button("Next") {
                                    nextQuestion()
                                }
                                .primaryButtonStyle()
                                .disabled(selectedAnswers[safe: currentQuizQuestion] == nil)
                            } else {
                                Button("Finish Quiz") {
                                    finishQuiz()
                                }
                                .accentButtonStyle()
                                .disabled(selectedAnswers[safe: currentQuizQuestion] == nil)
                            }
                        }
                        .padding(.horizontal, DeviceInfo.adaptivePadding)
                    }
                }
                .padding(DeviceInfo.adaptivePadding)
            } else {
                // iPhone: Original vertical layout
                VStack(spacing: 24) {
                    if let quiz = lesson.quiz,
                       currentQuizQuestion < quiz.questions.count {
                        let question = quiz.questions[currentQuizQuestion]
                        
                        // Question
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Question \(currentQuizQuestion + 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(question.text)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(ColorPalette.onSurface)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .cardStyle()
                        
                        // Answer Options
                        VStack(spacing: 12) {
                            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                                QuizAnswerOption(
                                    text: option,
                                    index: index,
                                    isSelected: selectedAnswers[safe: currentQuizQuestion] == index,
                                    color: module.category.color
                                ) {
                                    selectAnswer(index)
                                }
                            }
                        }
                        
                        // Navigation
                        HStack {
                            if currentQuizQuestion > 0 {
                                Button("Previous") {
                                    previousQuestion()
                                }
                                .secondaryButtonStyle()
                            }
                            
                            Spacer()
                            
                            if currentQuizQuestion < quiz.questions.count - 1 {
                                Button("Next") {
                                    nextQuestion()
                                }
                                .primaryButtonStyle()
                                .disabled(selectedAnswers[safe: currentQuizQuestion] == nil)
                            } else {
                                Button("Finish Quiz") {
                                    finishQuiz()
                                }
                                .accentButtonStyle()
                                .disabled(selectedAnswers[safe: currentQuizQuestion] == nil)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var quizResultsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let quiz = lesson.quiz {
                    // Results Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(scoreColor.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Text("\(quiz.score)/\(quiz.questions.count)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(scoreColor)
                        }
                        
                        Text(scoreMessage)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorPalette.onSurface)
                        
                        Text("You scored \(quiz.score) out of \(quiz.questions.count) questions correctly")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .cardStyle()
                    
                    // Questions Review
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Review")
                            .font(.headline)
                            .foregroundColor(ColorPalette.onSurface)
                        
                        ForEach(Array(quiz.questions.enumerated()), id: \.element.id) { index, question in
                            QuizResultRow(
                                question: question,
                                questionNumber: index + 1,
                                userAnswer: selectedAnswers[safe: index] ?? nil,
                                module: module
                            )
                        }
                    }
                    .padding()
                    .cardStyle()
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button("Continue Learning") {
                            completeLesson()
                        }
                        .frame(maxWidth: .infinity)
                        .accentButtonStyle()
                        
                        Button("Retake Quiz") {
                            retakeQuiz()
                        }
                        .frame(maxWidth: .infinity)
                        .secondaryButtonStyle()
                    }
                }
            }
            .padding()
        }
    }
    
    private var canNavigateToPrevious: Bool {
        viewModel.currentLesson != nil && viewModel.currentModule?.lessons.first?.id != lesson.id
    }
    
    private var canNavigateToNext: Bool {
        guard let module = viewModel.currentModule,
              let currentIndex = module.lessons.firstIndex(where: { $0.id == lesson.id }) else { return false }
        return currentIndex < module.lessons.count - 1
    }
    
    private var scoreColor: Color {
        guard let quiz = lesson.quiz else { return .gray }
        let percentage = Double(quiz.score) / Double(quiz.questions.count)
        if percentage >= 0.8 { return ColorPalette.success }
        if percentage >= 0.6 { return ColorPalette.accentBackground }
        return ColorPalette.destructive
    }
    
    private var scoreMessage: String {
        guard let quiz = lesson.quiz else { return "" }
        let percentage = Double(quiz.score) / Double(quiz.questions.count)
        if percentage >= 0.8 { return "Excellent!" }
        if percentage >= 0.6 { return "Good Job!" }
        return "Keep Learning!"
    }
    
    private func setupQuiz() {
        if let quiz = lesson.quiz {
            selectedAnswers = Array(repeating: nil, count: quiz.questions.count)
        }
    }
    
    private func startQuiz() {
        setupQuiz()
        currentQuizQuestion = 0
        showingQuiz = true
        showingResults = false
    }
    
    private func selectAnswer(_ index: Int) {
        selectedAnswers[currentQuizQuestion] = index
    }
    
    private func nextQuestion() {
        if currentQuizQuestion < (lesson.quiz?.questions.count ?? 0) - 1 {
            currentQuizQuestion += 1
        }
    }
    
    private func previousQuestion() {
        if currentQuizQuestion > 0 {
            currentQuizQuestion -= 1
        }
    }
    
    private func finishQuiz() {
        // Calculate score and mark quiz as completed
        guard let quiz = lesson.quiz else { return }
        
        for (index, question) in quiz.questions.enumerated() {
            if let userAnswer = selectedAnswers[safe: index], let answer = userAnswer {
                viewModel.submitQuizAnswer(questionId: question.id, answer: answer)
            }
        }
        
        showingResults = true
    }
    
    private func retakeQuiz() {
        setupQuiz()
        currentQuizQuestion = 0
        showingResults = false
    }
    
    private func exitQuiz() {
        showingQuiz = false
    }
    
    private func completeLesson() {
        HapticFeedback.notification(.success)
        viewModel.completeLesson(lesson)
        
        if canNavigateToNext {
            navigateToNext()
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func navigateToNext() {
        viewModel.nextLesson()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func navigateToPrevious() {
        viewModel.previousLesson()
        presentationMode.wrappedValue.dismiss()
    }
}

struct QuizAnswerOption: View {
    let text: String
    let index: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticFeedback.selection()
            action()
        }) {
            HStack {
                ZStack {
                    Circle()
                        .fill(isSelected ? color : Color(.systemGray5))
                        .frame(width: 24, height: 24)
                    
                    Text("\(Character(UnicodeScalar(65 + index)!))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                Text(text)
                    .font(.body)
                    .foregroundColor(ColorPalette.onSurface)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(DeviceInfo.isPad ? 20 : 16)
            .frame(minHeight: DeviceInfo.minTouchTargetSize)
            .background(isSelected ? color.opacity(0.1) : ColorPalette.surface)
            .cornerRadius(DeviceInfo.isPad ? 16 : 12)
            .overlay(
                RoundedRectangle(cornerRadius: DeviceInfo.isPad ? 16 : 12)
                    .stroke(isSelected ? color : Color(.systemGray4), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuizResultRow: View {
    let question: Question
    let questionNumber: Int
    let userAnswer: Int?
    let module: EducationalModule
    
    private var isCorrect: Bool {
        userAnswer == question.correctAnswer
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Question
            HStack {
                ZStack {
                    Circle()
                        .fill(isCorrect ? ColorPalette.success.opacity(0.2) : ColorPalette.destructive.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: isCorrect ? "checkmark" : "xmark")
                        .font(.caption)
                        .foregroundColor(isCorrect ? ColorPalette.success : ColorPalette.destructive)
                }
                
                Text("Question \(questionNumber)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ColorPalette.onSurface)
                
                Spacer()
            }
            
            Text(question.text)
                .font(.body)
                .foregroundColor(ColorPalette.onSurface)
            
            // Your Answer
            if let userAnswer = userAnswer {
                HStack {
                    Text("Your answer:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(question.options[userAnswer])
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(isCorrect ? ColorPalette.success : ColorPalette.destructive)
                }
            }
            
            // Correct Answer
            if !isCorrect {
                HStack {
                    Text("Correct answer:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(question.options[question.correctAnswer])
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.success)
                }
            }
            
            // Explanation
            if !question.explanation.isEmpty {
                Text(question.explanation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(ColorPalette.surface)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isCorrect ? ColorPalette.success.opacity(0.3) : ColorPalette.destructive.opacity(0.3), lineWidth: 1)
        )
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    LessonView(
        lesson: Lesson(
            title: "Introduction to SwiftUI",
            content: "SwiftUI is a revolutionary framework that makes building user interfaces faster and more enjoyable. It uses a declarative syntax that's easy to read and natural to write.",
            duration: 600,
            quiz: Quiz(questions: [
                Question(
                    text: "What is SwiftUI?",
                    options: ["A database", "A UI framework", "A networking library", "A testing tool"],
                    correctAnswer: 1,
                    explanation: "SwiftUI is Apple's declarative UI framework."
                )
            ])
        ),
        module: EducationalModule(
            title: "SwiftUI Fundamentals",
            description: "Learn SwiftUI basics",
            difficulty: .beginner,
            category: .technology,
            lessons: []
        ),
        viewModel: EducationViewModel()
    )
} 
