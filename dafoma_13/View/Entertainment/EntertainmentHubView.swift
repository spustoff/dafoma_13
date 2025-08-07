import SwiftUI

struct EntertainmentHubView: View {
    @ObservedObject var viewModel: EntertainmentViewModel
    @State private var showingAddMedia = false
    @State private var showingCreatePlaylist = false
    @State private var showingFilters = false
    @State private var selectedPlaylist: Playlist?
    
    var body: some View {
        ZStack {
            ColorPalette.surface.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                headerView
                
                // Quick Stats
                quickStatsView
                
                // Filter Section
                if showingFilters {
                    filterSectionView
                        .transition(.slide)
                }
                
                // Content Tabs
                contentTabsView
            }
        }
        .navigationBarStyle()
        .navigationTitle("Entertainment Hub")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingFilters.toggle() }) {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    
                    Button(action: { viewModel.clearFilters() }) {
                        Label("Clear Filters", systemImage: "xmark.circle")
                    }
                    
                    Button(action: { showingAddMedia = true }) {
                        Label("Add Media", systemImage: "plus.circle")
                    }
                    
                    Button(action: { showingCreatePlaylist = true }) {
                        Label("Create Playlist", systemImage: "music.note.list")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAddMedia) {
            AddMediaView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingCreatePlaylist) {
            CreatePlaylistView(viewModel: viewModel)
        }
        .sheet(item: $selectedPlaylist) { playlist in
            PlaylistDetailView(playlist: playlist, viewModel: viewModel)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Creative Hub")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Discover and curate amazing content")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Button(action: { showingAddMedia = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [ColorPalette.accentBackground, ColorPalette.accentBackground.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var quickStatsView: some View {
        Group {
            if DeviceInfo.isPad {
                // iPad: Grid layout for stats
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: min(4, allQuickStatCards.count)),
                    spacing: DeviceInfo.adaptiveSpacing
                ) {
                    ForEach(Array(allQuickStatCards.enumerated()), id: \.offset) { _, card in
                        card
                    }
                }
                .padding(DeviceInfo.adaptivePadding)
            } else {
                // iPhone: Horizontal scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(allQuickStatCards.enumerated()), id: \.offset) { _, card in
                            card
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
    }
    
    private var allQuickStatCards: [StatCard] {
        var cards = [
            StatCard(
                title: "Total Items",
                value: "\(viewModel.mediaItems.count)",
                color: ColorPalette.primaryBackground,
                icon: "rectangle.stack"
            ),
            StatCard(
                title: "Favorites",
                value: "\(viewModel.favoriteItems.count)",
                color: ColorPalette.destructive,
                icon: "heart.fill"
            ),
            StatCard(
                title: "Playlists",
                value: "\(viewModel.playlists.count)",
                color: ColorPalette.success,
                icon: "music.note.list"
            )
        ]
        
        for type in MediaItem.MediaType.allCases {
            let count = viewModel.mediaItems.filter { $0.type == type }.count
            if count > 0 {
                cards.append(StatCard(
                    title: type.rawValue,
                    value: "\(count)",
                    color: ColorPalette.secondaryBackground,
                    icon: type.icon
                ))
            }
        }
        
        return cards
    }
    
    private var filterSectionView: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search media...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Media Type Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "All Types",
                        isSelected: viewModel.selectedMediaType == nil,
                        color: ColorPalette.onSurface
                    ) {
                        viewModel.selectedMediaType = nil
                    }
                    
                    ForEach(MediaItem.MediaType.allCases, id: \.self) { type in
                        FilterChip(
                            title: type.rawValue,
                            isSelected: viewModel.selectedMediaType == type,
                            color: ColorPalette.accentBackground
                        ) {
                            viewModel.selectedMediaType = type
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(ColorPalette.surface)
    }
    
    private var contentTabsView: some View {
        TabView {
            // Media Items Tab
            mediaItemsView
                .tabItem {
                    Image(systemName: "rectangle.stack")
                    Text("Media")
                }
            
            // Playlists Tab
            playlistsView
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Playlists")
                }
            
            // Favorites Tab
            favoritesView
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
        }
        .accentColor(ColorPalette.accentBackground)
    }
    
    private var mediaItemsView: some View {
        Group {
            if viewModel.filteredMediaItems.isEmpty {
                emptyMediaStateView
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: DeviceInfo.isPad ? 3 : 2),
                        spacing: DeviceInfo.adaptiveSpacing
                    ) {
                        ForEach(viewModel.filteredMediaItems) { item in
                            MediaItemCard(item: item, viewModel: viewModel)
                        }
                    }
                    .padding(DeviceInfo.adaptivePadding)
                }
            }
        }
    }
    
    private var playlistsView: some View {
        Group {
            if viewModel.playlists.isEmpty {
                emptyPlaylistsStateView
            } else {
                List {
                    ForEach(viewModel.playlists) { playlist in
                        PlaylistRowView(playlist: playlist) {
                            selectedPlaylist = playlist
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    private var favoritesView: some View {
        Group {
            if viewModel.favoriteItems.isEmpty {
                emptyFavoritesStateView
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: DeviceInfo.isPad ? 3 : 2),
                        spacing: DeviceInfo.adaptiveSpacing
                    ) {
                        ForEach(viewModel.favoriteItems) { item in
                            MediaItemCard(item: item, viewModel: viewModel)
                        }
                    }
                    .padding(DeviceInfo.adaptivePadding)
                }
            }
        }
    }
    
    private var emptyMediaStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tv")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No media found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Add your first media item to start building your entertainment collection")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Add Media") {
                showingAddMedia = true
            }
            .accentButtonStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.surface)
    }
    
    private var emptyPlaylistsStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No playlists created")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Create playlists to organize your media collection")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Create Playlist") {
                showingCreatePlaylist = true
            }
            .accentButtonStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.surface)
    }
    
    private var emptyFavoritesStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No favorites yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Mark items as favorites to see them here")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.surface)
    }
}

struct MediaItemCard: View {
    let item: MediaItem
    @ObservedObject var viewModel: EntertainmentViewModel
    @State private var showingDetails = false
    
    var body: some View {
        Button(action: { showingDetails = true }) {
            VStack(spacing: 12) {
                // Icon and Type
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(typeColor.opacity(0.2))
                        .frame(height: 80)
                    
                    VStack(spacing: 4) {
                        Image(systemName: item.imageName ?? item.type.icon)
                            .font(.title)
                            .foregroundColor(typeColor)
                        
                        Text(item.type.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(typeColor)
                    }
                }
                
                // Content Info
                VStack(spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorPalette.onSurface)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    Text(item.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Rating
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < item.rating ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(ColorPalette.accentBackground)
                        }
                    }
                }
                
                // Favorite Button
                Button(action: {
                    HapticFeedback.impact(.light)
                    viewModel.toggleFavorite(item)
                }) {
                    Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(item.isFavorite ? ColorPalette.destructive : .gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetails) {
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

struct PlaylistRowView: View {
    let playlist: Playlist
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Playlist Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: playlist.colorTheme).opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "music.note.list")
                        .font(.title2)
                        .foregroundColor(Color(hex: playlist.colorTheme))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(playlist.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorPalette.onSurface)
                    
                    Text(playlist.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    Text("\(playlist.items.count) items")
                        .font(.caption2)
                        .foregroundColor(Color(hex: playlist.colorTheme))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        EntertainmentHubView(viewModel: EntertainmentViewModel())
    }
} 