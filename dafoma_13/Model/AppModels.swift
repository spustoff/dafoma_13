import Foundation
import SwiftUI

// MARK: - Task Management Models
struct Task: Identifiable, Codable, Equatable {
    let id = UUID()
    var title: String
    var description: String
    var priority: TaskPriority
    var category: TaskCategory
    var isCompleted: Bool = false
    var createdDate: Date = Date()
    var dueDate: Date?
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }
    
    enum TaskPriority: String, CaseIterable, Codable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var color: Color {
            switch self {
            case .high: return ColorPalette.destructive
            case .medium: return ColorPalette.alert
            case .low: return ColorPalette.success
            }
        }
    }
    
    enum TaskCategory: String, CaseIterable, Codable {
        case business = "Business"
        case personal = "Personal"
        case creative = "Creative"
        case education = "Education"
        
        var color: Color {
            switch self {
            case .business: return ColorPalette.primaryBackground
            case .personal: return ColorPalette.secondaryBackground
            case .creative: return ColorPalette.accentBackground
            case .education: return ColorPalette.success
            }
        }
    }
}

// MARK: - Entertainment Models
struct MediaItem: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var type: MediaType
    var category: String
    var isFavorite: Bool = false
    var rating: Int = 0
    var imageName: String?
    
    enum MediaType: String, CaseIterable, Codable {
        case music = "Music"
        case video = "Video"
        case art = "Art"
        case podcast = "Podcast"
        
        var icon: String {
            switch self {
            case .music: return "music.note"
            case .video: return "play.rectangle"
            case .art: return "paintbrush"
            case .podcast: return "mic"
            }
        }
    }
}

struct Playlist: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var items: [MediaItem] = []
    var colorTheme: String
    var createdDate: Date = Date()
}

// MARK: - Education Models
struct EducationalModule: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var difficulty: Difficulty
    var category: EducationCategory
    var lessons: [Lesson] = []
    var isCompleted: Bool = false
    var progress: Double = 0.0
    
    enum Difficulty: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        
        var color: Color {
            switch self {
            case .beginner: return ColorPalette.success
            case .intermediate: return ColorPalette.alert
            case .advanced: return ColorPalette.destructive
            }
        }
    }
    
    enum EducationCategory: String, CaseIterable, Codable {
        case technology = "Technology"
        case design = "Design"
        case business = "Business"
        case languages = "Languages"
        case science = "Science"
        
        var color: Color {
            switch self {
            case .technology: return ColorPalette.primaryBackground
            case .design: return ColorPalette.accentBackground
            case .business: return ColorPalette.secondaryBackground
            case .languages: return ColorPalette.success
            case .science: return ColorPalette.alert
            }
        }
    }
}

struct Lesson: Identifiable, Codable {
    let id = UUID()
    var title: String
    var content: String
    var duration: TimeInterval
    var isCompleted: Bool = false
    var quiz: Quiz?
}

struct Quiz: Identifiable, Codable {
    let id = UUID()
    var questions: [Question]
    var score: Int = 0
    var isCompleted: Bool = false
}

struct Question: Identifiable, Codable {
    let id = UUID()
    var text: String
    var options: [String]
    var correctAnswer: Int
    var userAnswer: Int?
    var explanation: String
}

// MARK: - Onboarding Models
struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

// MARK: - App State
enum AppState {
    case onboarding
    case main
}

enum MainTab: CaseIterable {
    case coordinator
    case entertainment
    case education
    
    var title: String {
        switch self {
        case .coordinator: return "Coordinator"
        case .entertainment: return "Entertainment"
        case .education: return "Education"
        }
    }
    
    var icon: String {
        switch self {
        case .coordinator: return "checklist"
        case .entertainment: return "tv"
        case .education: return "book"
        }
    }
    
    var color: Color {
        switch self {
        case .coordinator: return ColorPalette.primaryBackground
        case .entertainment: return ColorPalette.accentBackground
        case .education: return ColorPalette.success
        }
    }
} 