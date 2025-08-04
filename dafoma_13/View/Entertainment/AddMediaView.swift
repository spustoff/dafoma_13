import SwiftUI

struct AddMediaView: View {
    @ObservedObject var viewModel: EntertainmentViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedType = MediaItem.MediaType.music
    @State private var category = ""
    @State private var rating = 3
    @State private var imageName = ""
    
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
            .navigationTitle("Add Media")
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
                        saveMedia()
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
                    .fill(typeColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: selectedType.icon)
                    .font(.system(size: 40))
                    .foregroundColor(typeColor)
            }
            
            Text("Add New Media")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.onSurface)
            
            Text("Expand your entertainment collection")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var formFieldsView: some View {
        VStack(spacing: 20) {
            // Title Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Title *")
                    .font(.headline)
                    .foregroundColor(ColorPalette.onSurface)
                
                TextField("Enter media title", text: $title)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            // Description Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)
                    .foregroundColor(ColorPalette.onSurface)
                
                TextField("Enter description", text: $description)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            // Type Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Media Type")
                    .font(.headline)
                    .foregroundColor(ColorPalette.onSurface)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(MediaItem.MediaType.allCases, id: \.self) { type in
                        MediaTypeSelectionCard(
                            type: type,
                            isSelected: selectedType == type
                        ) {
                            HapticFeedback.selection()
                            selectedType = type
                        }
                    }
                }
            }
            
            // Category Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.headline)
                    .foregroundColor(ColorPalette.onSurface)
                
                TextField("Enter category (e.g., Productivity, Design)", text: $category)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            // Rating Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Rating")
                    .font(.headline)
                    .foregroundColor(ColorPalette.onSurface)
                
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Button(action: {
                            HapticFeedback.selection()
                            rating = star
                        }) {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(star <= rating ? ColorPalette.accentBackground : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                    
                    Text("\(rating)/5")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Custom Icon Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Custom Icon (Optional)")
                    .font(.headline)
                    .foregroundColor(ColorPalette.onSurface)
                
                TextField("SF Symbol name (e.g., music.note.house)", text: $imageName)
                    .textFieldStyle(CustomTextFieldStyle())
                
                if !imageName.isEmpty {
                    HStack {
                        Text("Preview:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Image(systemName: imageName)
                            .font(.title2)
                            .foregroundColor(typeColor)
                        
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            Button("Add Media") {
                saveMedia()
            }
            .frame(maxWidth: .infinity)
            .accentButtonStyle()
            .disabled(title.isEmpty)
            
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .frame(maxWidth: .infinity)
            .secondaryButtonStyle()
        }
    }
    
    private var typeColor: Color {
        switch selectedType {
        case .music: return ColorPalette.success
        case .video: return ColorPalette.primaryBackground
        case .art: return ColorPalette.accentBackground
        case .podcast: return ColorPalette.secondaryBackground
        }
    }
    
    private func saveMedia() {
        guard !title.isEmpty else { return }
        
        let newMediaItem = MediaItem(
            title: title,
            description: description,
            type: selectedType,
            category: category.isEmpty ? selectedType.rawValue : category,
            rating: rating,
            imageName: imageName.isEmpty ? nil : imageName
        )
        
        HapticFeedback.notification(.success)
        viewModel.addMediaItem(newMediaItem)
        presentationMode.wrappedValue.dismiss()
    }
}

struct MediaTypeSelectionCard: View {
    let type: MediaItem.MediaType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(typeColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: type.icon)
                        .font(.title2)
                        .foregroundColor(typeColor)
                }
                
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : ColorPalette.onSurface)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? typeColor : ColorPalette.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(typeColor, lineWidth: isSelected ? 0 : 1)
            )
            .shadow(color: isSelected ? typeColor.opacity(0.3) : Color.clear, radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var typeColor: Color {
        switch type {
        case .music: return ColorPalette.success
        case .video: return ColorPalette.primaryBackground
        case .art: return ColorPalette.accentBackground
        case .podcast: return ColorPalette.secondaryBackground
        }
    }
}

#Preview {
    AddMediaView(viewModel: EntertainmentViewModel())
} 
