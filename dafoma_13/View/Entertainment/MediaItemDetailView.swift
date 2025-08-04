import SwiftUI

struct MediaItemDetailView: View {
    let item: MediaItem
    @ObservedObject var viewModel: EntertainmentViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var showingPlaylistSelector = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        typeColor.opacity(0.1),
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
                        
                        // Content Details
                        contentDetailsView
                        
                        // Action Buttons
                        actionButtonsView
                        
                        // Available Playlists
                        if !viewModel.playlists.isEmpty {
                            playlistSectionView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Media Details")
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
                        Button(action: {
                            HapticFeedback.impact(.light)
                            viewModel.toggleFavorite(item)
                        }) {
                            Label(item.isFavorite ? "Remove from Favorites" : "Add to Favorites", 
                                  systemImage: item.isFavorite ? "heart.slash" : "heart")
                        }
                        
                        Button(action: { showingPlaylistSelector = true }) {
                            Label("Add to Playlist", systemImage: "plus.circle")
                        }
                        
                        Button(action: { showingDeleteAlert = true }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
            }
        }
        .alert("Delete Media Item", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteItem()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this media item? This action cannot be undone.")
        }
        .sheet(isPresented: $showingPlaylistSelector) {
            PlaylistSelectorView(item: item, viewModel: viewModel)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Media Icon
            ZStack {
                Circle()
                    .fill(typeColor.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: item.imageName ?? item.type.icon)
                    .font(.system(size: 60))
                    .foregroundColor(typeColor)
            }
            
            // Title and Type
            VStack(spacing: 8) {
                Text(item.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorPalette.onSurface)
                    .multilineTextAlignment(.center)
                
                Text(item.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(typeColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(typeColor.opacity(0.2))
                    .cornerRadius(12)
            }
            
            // Rating
            HStack(spacing: 4) {
                ForEach(0..<5) { index in
                    Image(systemName: index < item.rating ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundColor(ColorPalette.accentBackground)
                }
                
                Text("(\(item.rating)/5)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
            
            // Favorite Button
            Button(action: {
                HapticFeedback.impact(.medium)
                withAnimation(.paletteSpring) {
                    viewModel.toggleFavorite(item)
                }
            }) {
                HStack {
                    Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                    Text(item.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                }
                .font(.headline)
                .foregroundColor(item.isFavorite ? ColorPalette.destructive : .gray)
            }
        }
    }
    
    private var contentDetailsView: some View {
        VStack(spacing: 20) {
            // Description
            if !item.description.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(ColorPalette.onSurface)
                    
                    Text(item.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .cardStyle()
            }
            
            // Properties
            VStack(spacing: 16) {
                PropertyRow(
                    title: "Category",
                    value: item.category,
                    color: typeColor,
                    icon: "folder.fill"
                )
                
                PropertyRow(
                    title: "Media Type",
                    value: item.type.rawValue,
                    color: typeColor,
                    icon: item.type.icon
                )
                
                PropertyRow(
                    title: "Rating",
                    value: "\(item.rating) out of 5 stars",
                    color: ColorPalette.accentBackground,
                    icon: "star.fill"
                )
                
                PropertyRow(
                    title: "Favorite",
                    value: item.isFavorite ? "Yes" : "No",
                    color: item.isFavorite ? ColorPalette.destructive : .gray,
                    icon: item.isFavorite ? "heart.fill" : "heart"
                )
            }
            .padding()
            .cardStyle()
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            Button("Add to Playlist") {
                showingPlaylistSelector = true
            }
            .frame(maxWidth: .infinity)
            .accentButtonStyle()
            
            Button("Delete Media Item") {
                showingDeleteAlert = true
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(ColorPalette.destructive)
            .cornerRadius(8)
            .shadow(color: ColorPalette.destructive.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
    
    private var playlistSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add to Playlists")
                .font(.headline)
                .foregroundColor(ColorPalette.onSurface)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.playlists) { playlist in
                        PlaylistMiniCard(
                            playlist: playlist,
                            isItemInPlaylist: playlist.items.contains { $0.id == item.id }
                        ) {
                            if playlist.items.contains(where: { $0.id == item.id }) {
                                viewModel.removeFromPlaylist(item, playlistId: playlist.id)
                            } else {
                                viewModel.addToPlaylist(item, playlistId: playlist.id)
                            }
                            HapticFeedback.impact(.light)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .cardStyle()
    }
    
    private var typeColor: Color {
        switch item.type {
        case .music: return ColorPalette.success
        case .video: return ColorPalette.primaryBackground
        case .art: return ColorPalette.accentBackground
        case .podcast: return ColorPalette.secondaryBackground
        }
    }
    
    private func deleteItem() {
        HapticFeedback.notification(.warning)
        viewModel.deleteMediaItem(item)
        presentationMode.wrappedValue.dismiss()
    }
}

struct PlaylistMiniCard: View {
    let playlist: Playlist
    let isItemInPlaylist: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: playlist.colorTheme).opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: isItemInPlaylist ? "checkmark.circle.fill" : "plus.circle")
                        .font(.title2)
                        .foregroundColor(Color(hex: playlist.colorTheme))
                }
                
                Text(playlist.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(ColorPalette.onSurface)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlaylistSelectorView: View {
    let item: MediaItem
    @ObservedObject var viewModel: EntertainmentViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.playlists) { playlist in
                    let isInPlaylist = playlist.items.contains { $0.id == item.id }
                    
                    Button(action: {
                        if isInPlaylist {
                            viewModel.removeFromPlaylist(item, playlistId: playlist.id)
                        } else {
                            viewModel.addToPlaylist(item, playlistId: playlist.id)
                        }
                        HapticFeedback.impact(.light)
                    }) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: playlist.colorTheme).opacity(0.2))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "music.note.list")
                                    .foregroundColor(Color(hex: playlist.colorTheme))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(playlist.name)
                                    .font(.headline)
                                    .foregroundColor(ColorPalette.onSurface)
                                
                                Text("\(playlist.items.count) items")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: isInPlaylist ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isInPlaylist ? ColorPalette.success : .gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Select Playlists")
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
}

#Preview {
    MediaItemDetailView(
        item: MediaItem(
            title: "Sample Media",
            description: "This is a sample media item",
            type: .music,
            category: "Productivity",
            rating: 4
        ),
        viewModel: EntertainmentViewModel()
    )
} 