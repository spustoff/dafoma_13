import SwiftUI

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func cardStyle() -> some View {
        self
            .background(ColorPalette.surface)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(ColorPalette.primaryBackground)
            .cornerRadius(8)
            .shadow(color: ColorPalette.primaryBackground.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .foregroundColor(ColorPalette.primaryBackground)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(ColorPalette.secondaryBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(ColorPalette.primaryBackground, lineWidth: 1)
            )
    }
    
    func accentButtonStyle() -> some View {
        self
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(ColorPalette.accentBackground)
            .cornerRadius(8)
            .shadow(color: ColorPalette.accentBackground.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    func navigationBarStyle() -> some View {
        self
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // Configure navigation bar appearance for iOS 15.6 compatibility
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(ColorPalette.primaryBackground)
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
                UINavigationBar.appearance().tintColor = UIColor.white
            }
    }
}

// MARK: - Custom Shapes
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - String Extensions
extension String {
    func limitLength(_ maxLength: Int) -> String {
        if self.count > maxLength {
            return String(self.prefix(maxLength)) + "..."
        }
        return self
    }
}

// MARK: - Date Extensions
extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(self) {
            let components = calendar.dateComponents([.hour, .minute], from: self, to: now)
            if let hours = components.hour, hours > 0 {
                return "\(hours)h ago"
            } else if let minutes = components.minute, minutes > 0 {
                return "\(minutes)m ago"
            } else {
                return "Just now"
            }
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: self)
        }
    }
    
    func dueDateDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            let components = calendar.dateComponents([.day], from: now, to: self)
            if let days = components.day {
                if days > 0 {
                    return "In \(days) day\(days == 1 ? "" : "s")"
                } else {
                    return "\(abs(days)) day\(abs(days) == 1 ? "" : "s") overdue"
                }
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}

// MARK: - Double Extensions
extension Double {
    func asProgressPercentage() -> String {
        return String(format: "%.0f%%", self * 100)
    }
    
    func asRating() -> String {
        return String(format: "%.1f", self)
    }
}

// MARK: - TimeInterval Extensions
extension TimeInterval {
    func asFormattedDuration() -> String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

// MARK: - Haptic Feedback
struct HapticFeedback {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(type)
    }
    
    static func selection() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
}

// MARK: - Animation Extensions
extension Animation {
    static let paletteSpring = Animation.spring()
    static let paletteEaseInOut = Animation.easeInOut(duration: 0.3)
    static let paletteDefault = Animation.default
}

// MARK: - Device Info
struct DeviceInfo {
    static let isPhone = UIDevice.current.userInterfaceIdiom == .phone
    static let isPad = UIDevice.current.userInterfaceIdiom == .pad
    
    static var screenSize: CGSize {
        UIScreen.main.bounds.size
    }
    
    static var isSmallScreen: Bool {
        screenSize.height < 700
    }
} 