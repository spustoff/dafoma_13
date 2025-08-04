import SwiftUI

struct CreatePlaylistView: View {
    @ObservedObject var viewModel: EntertainmentViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedColorTheme = "#ffc934"
    
    private let colorThemes = [
        "#ae2d27", "#dfb492", "#ffc934", "#1ed55f", "#ffff03", "#eb262f",
        "#3498db", "#9b59b6", "#e67e22", "#2ecc71", "#e74c3c", "#f39c12"
    ]
    
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
                        
                        // Color Theme Selection
                        colorThemeSelectionView
                        
                        // Action Buttons
                        actionButtonsView
                    }
                    .padding()
                }
            }
            .navigationTitle("Create Playlist")
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
                    Button("Create") {
                        createPlaylist()
                    }
                    .foregroundColor(.white)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: selectedColorTheme).opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "music.note.list")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: selectedColorTheme))
            }
            
            Text("Create New Playlist")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.onSurface)
            
            Text("Organize your media with a personalized playlist")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var formFieldsView: some View {
        VStack(spacing: 20) {
            // Name Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Playlist Name *")
                    .font(.headline)
                    .foregroundColor(ColorPalette.onSurface)
                
                TextField("Enter playlist name", text: $name)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            // Description Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)
                    .foregroundColor(ColorPalette.onSurface)
                
                TextField("Enter playlist description", text: $description)
                    .textFieldStyle(CustomTextFieldStyle())
            }
        }
    }
    
    private var colorThemeSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Color Theme")
                .font(.headline)
                .foregroundColor(ColorPalette.onSurface)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                ForEach(colorThemes, id: \.self) { colorHex in
                    ColorThemeButton(
                        colorHex: colorHex,
                        isSelected: selectedColorTheme == colorHex
                    ) {
                        HapticFeedback.selection()
                        selectedColorTheme = colorHex
                    }
                }
            }
            
            // Preview
            VStack(spacing: 12) {
                Text("Preview")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: selectedColorTheme).opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "music.note.list")
                            .font(.title2)
                            .foregroundColor(Color(hex: selectedColorTheme))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name.isEmpty ? "My Playlist" : name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorPalette.onSurface)
                        
                        Text(description.isEmpty ? "Playlist description" : description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        Text("0 items")
                            .font(.caption2)
                            .foregroundColor(Color(hex: selectedColorTheme))
                    }
                    
                    Spacer()
                }
                .padding()
                .cardStyle()
            }
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            Button("Create Playlist") {
                createPlaylist()
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(hex: selectedColorTheme))
            .cornerRadius(8)
            .shadow(color: Color(hex: selectedColorTheme).opacity(0.3), radius: 4, x: 0, y: 2)
            .disabled(name.isEmpty)
            
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .frame(maxWidth: .infinity)
            .secondaryButtonStyle()
        }
    }
    
    private func createPlaylist() {
        guard !name.isEmpty else { return }
        
        HapticFeedback.notification(.success)
        viewModel.createPlaylist(
            name: name,
            description: description,
            colorTheme: selectedColorTheme
        )
        presentationMode.wrappedValue.dismiss()
    }
}

struct ColorThemeButton: View {
    let colorHex: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(hex: colorHex))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(ColorPalette.onSurface, lineWidth: isSelected ? 3 : 0)
                    )
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.paletteSpring, value: isSelected)
    }
}

#Preview {
    CreatePlaylistView(viewModel: EntertainmentViewModel())
} 
