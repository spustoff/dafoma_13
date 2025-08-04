import SwiftUI

struct PlaylistDetailView: View {
    let playlist: Playlist
    @ObservedObject var viewModel: EntertainmentViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingDeleteAlert = false
    @State private var showingMediaSelector = false
    
    private var playlistItems: [MediaItem] {
        playlist.items
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: playlist.colorTheme).opacity(0.1),
                        ColorPalette.surface
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Content
                    contentView
                }
            }
            .navigationTitle("Playlist")
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
                    Menu {
                        Button(action: { showingMediaSelector = true }) {
                            Label("Add Media", systemImage: "plus.circle")
                        }
                        
                        Button(action: { showingDeleteAlert = true }) {
                            Label("Delete Playlist", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
            }
        }
        .alert("Delete Playlist", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deletePlaylist()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this playlist? This action cannot be undone.")
        }
        .sheet(isPresented: $showingMediaSelector) {
            MediaSelectorView(playlist: playlist, viewModel: viewModel)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 20) {
            // Playlist Icon
            ZStack {
                Circle()
                    .fill(Color(hex: playlist.colorTheme).opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "music.note.list")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: playlist.colorTheme))
            }
            
            // Playlist Info
            VStack(spacing: 8) {
                Text(playlist.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorPalette.onSurface)
                    .multilineTextAlignment(.center)
                
                if !playlist.description.isEmpty {
                    Text(playlist.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Text("\(playlistItems.count) items")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: playlist.colorTheme))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(hex: playlist.colorTheme).opacity(0.2))
                    .cornerRadius(12)
            }
            
            // Action Buttons
            HStack(spacing: 16) {
                Button("Add Media") {
                    showingMediaSelector = true
                }
                .accentButtonStyle()
                
                if !playlistItems.isEmpty {
                    Button("Shuffle Play") {
                        // Add shuffle functionality here
                        HapticFeedback.impact(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(hex: playlist.colorTheme))
                    .cornerRadius(8)
                    .shadow(color: Color(hex: playlist.colorTheme).opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(hex: playlist.colorTheme).opacity(0.1),
                    Color(hex: playlist.colorTheme).opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var contentView: some View {
        Group {
            if playlistItems.isEmpty {
                emptyPlaylistView
            } else {
                playlistItemsView
            }
        }
    }
    
    private var emptyPlaylistView: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Empty Playlist")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Add media items to your playlist to get started")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Add Media") {
                showingMediaSelector = true
            }
            .accentButtonStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.surface)
    }
    
    private var playlistItemsView: some View {
        List {
            ForEach(Array(playlistItems.enumerated()), id: \.element.id) { index, item in
                PlaylistItemRow(
                    item: item,
                    index: index + 1,
                    playlist: playlist,
                    viewModel: viewModel
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func deletePlaylist() {
        HapticFeedback.notification(.warning)
        viewModel.deletePlaylist(playlist)
        presentationMode.wrappedValue.dismiss()
    }
}

struct PlaylistItemRow: View {
    let item: MediaItem
    let index: Int
    let playlist: Playlist
    @ObservedObject var viewModel: EntertainmentViewModel
    @State private var showingItemDetail = false
    
    var body: some View {
        Button(action: { showingItemDetail = true }) {
            HStack(spacing: 12) {
                // Index Number
                ZStack {
                    Circle()
                        .fill(Color(hex: playlist.colorTheme).opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Text("\(index)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: playlist.colorTheme))
                }
                
                // Media Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(typeColor.opacity(0.2))
                        .frame(width: 45, height: 45)
                    
                    Image(systemName: item.imageName ?? item.type.icon)
                        .font(.title3)
                        .foregroundColor(typeColor)
                }
                
                // Content Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.onSurface)
                        .lineLimit(1)
                    
                    Text(item.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Rating
                    HStack(spacing: 2) {
                        ForEach(0..<item.rating) { _ in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(ColorPalette.accentBackground)
                        }
                    }
                }
                
                Spacer()
                
                // Remove Button
                Button(action: {
                    HapticFeedback.impact(.light)
                    viewModel.removeFromPlaylist(item, playlistId: playlist.id)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingItemDetail) {
            MediaItemDetailView(item: item, viewModel: viewModel)
        }
    }
    
    private var typeColor: Color {
        switch item.type {
        case .music: return ColorPalette.success
        case .video: return ColorPalette.primaryBackground
        case .art: return ColorPalette.accentBackground
        case .podcast: return ColorPalette.secondaryBackground
        }
    }
}

struct MediaSelectorView: View {
    let playlist: Playlist
    @ObservedObject var viewModel: EntertainmentViewModel
    @Environment(\.presentationMode) var presentationMode
    
    private var availableMediaItems: [MediaItem] {
        viewModel.mediaItems.filter { item in
            !playlist.items.contains { $0.id == item.id }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if availableMediaItems.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(availableMediaItems) { item in
                            MediaItemSelectionRow(
                                item: item,
                                playlist: playlist,
                                viewModel: viewModel
                            )
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Add Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Available Media")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("All your media items are already in this playlist")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.surface)
    }
}

struct MediaItemSelectionRow: View {
    let item: MediaItem
    let playlist: Playlist
    @ObservedObject var viewModel: EntertainmentViewModel
    
    var body: some View {
        Button(action: {
            HapticFeedback.impact(.light)
            viewModel.addToPlaylist(item, playlistId: playlist.id)
        }) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(typeColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: item.imageName ?? item.type.icon)
                        .foregroundColor(typeColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(ColorPalette.onSurface)
                    
                    Text(item.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle")
                    .foregroundColor(Color(hex: playlist.colorTheme))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var typeColor: Color {
        switch item.type {
        case .music: return ColorPalette.success
        case .video: return ColorPalette.primaryBackground
        case .art: return ColorPalette.accentBackground
        case .podcast: return ColorPalette.secondaryBackground
        }
    }
}

#Preview {
    PlaylistDetailView(
        playlist: Playlist(
            name: "Sample Playlist",
            description: "A sample playlist for testing",
            colorTheme: "#ffc934"
        ),
        viewModel: EntertainmentViewModel()
    )
} 