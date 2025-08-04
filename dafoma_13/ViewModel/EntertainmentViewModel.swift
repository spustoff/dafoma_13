import SwiftUI
import Combine

@MainActor
class EntertainmentViewModel: ObservableObject {
    @Published var mediaItems: [MediaItem] = []
    @Published var playlists: [Playlist] = []
    @Published var selectedMediaType: MediaItem.MediaType? = nil
    @Published var searchText: String = ""
    @Published var showingCreatePlaylist: Bool = false
    @Published var favorites: [MediaItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let mediaItemsKey = "savedMediaItems"
    private let playlistsKey = "savedPlaylists"
    
    init() {
        loadData()
        setupSampleData()
    }
    
    var filteredMediaItems: [MediaItem] {
        mediaItems.filter { item in
            let matchesType = selectedMediaType == nil || item.type == selectedMediaType
            let matchesSearch = searchText.isEmpty ||
                item.title.localizedCaseInsensitiveContains(searchText) ||
                item.description.localizedCaseInsensitiveContains(searchText) ||
                item.category.localizedCaseInsensitiveContains(searchText)
            
            return matchesType && matchesSearch
        }
    }
    
    var mediaItemsByType: [MediaItem.MediaType: [MediaItem]] {
        Dictionary(grouping: filteredMediaItems) { $0.type }
    }
    
    var favoriteItems: [MediaItem] {
        mediaItems.filter { $0.isFavorite }
    }
    
    func addMediaItem(_ item: MediaItem) {
        mediaItems.append(item)
        saveData()
    }
    
    func updateMediaItem(_ item: MediaItem) {
        if let index = mediaItems.firstIndex(where: { $0.id == item.id }) {
            mediaItems[index] = item
            saveData()
        }
    }
    
    func deleteMediaItem(_ item: MediaItem) {
        mediaItems.removeAll { $0.id == item.id }
        // Remove from playlists as well
        for playlistIndex in playlists.indices {
            playlists[playlistIndex].items.removeAll { $0.id == item.id }
        }
        saveData()
    }
    
    func toggleFavorite(_ item: MediaItem) {
        if let index = mediaItems.firstIndex(where: { $0.id == item.id }) {
            mediaItems[index].isFavorite.toggle()
            saveData()
        }
    }
    
    func createPlaylist(name: String, description: String, colorTheme: String) {
        let playlist = Playlist(name: name, description: description, colorTheme: colorTheme)
        playlists.append(playlist)
        saveData()
    }
    
    func addToPlaylist(_ item: MediaItem, playlistId: UUID) {
        if let playlistIndex = playlists.firstIndex(where: { $0.id == playlistId }) {
            if !playlists[playlistIndex].items.contains(where: { $0.id == item.id }) {
                playlists[playlistIndex].items.append(item)
                saveData()
            }
        }
    }
    
    func removeFromPlaylist(_ item: MediaItem, playlistId: UUID) {
        if let playlistIndex = playlists.firstIndex(where: { $0.id == playlistId }) {
            playlists[playlistIndex].items.removeAll { $0.id == item.id }
            saveData()
        }
    }
    
    func deletePlaylist(_ playlist: Playlist) {
        playlists.removeAll { $0.id == playlist.id }
        saveData()
    }
    
    func clearFilters() {
        selectedMediaType = nil
        searchText = ""
    }
    
    private func saveData() {
        if let mediaData = try? JSONEncoder().encode(mediaItems) {
            userDefaults.set(mediaData, forKey: mediaItemsKey)
        }
        if let playlistData = try? JSONEncoder().encode(playlists) {
            userDefaults.set(playlistData, forKey: playlistsKey)
        }
    }
    
    private func loadData() {
        if let mediaData = userDefaults.data(forKey: mediaItemsKey),
           let decodedMedia = try? JSONDecoder().decode([MediaItem].self, from: mediaData) {
            mediaItems = decodedMedia
        }
        
        if let playlistData = userDefaults.data(forKey: playlistsKey),
           let decodedPlaylists = try? JSONDecoder().decode([Playlist].self, from: playlistData) {
            playlists = decodedPlaylists
        }
    }
    
    private func setupSampleData() {
        guard mediaItems.isEmpty else { return }
        
        let sampleMediaItems = [
            MediaItem(
                title: "Creative Focus Playlist",
                description: "Ambient music for productive work sessions",
                type: .music,
                category: "Productivity",
                rating: 5,
                imageName: "music.note.house"
            ),
            MediaItem(
                title: "Design Inspiration Gallery",
                description: "Collection of modern UI/UX designs",
                type: .art,
                category: "Design",
                rating: 4,
                imageName: "paintbrush.pointed"
            ),
            MediaItem(
                title: "SwiftUI Masterclass",
                description: "Advanced SwiftUI techniques and best practices",
                type: .video,
                category: "Education",
                rating: 5,
                imageName: "play.rectangle"
            ),
            MediaItem(
                title: "Tech Innovation Podcast",
                description: "Weekly discussions on latest technology trends",
                type: .podcast,
                category: "Technology",
                rating: 4,
                imageName: "mic.circle"
            ),
            MediaItem(
                title: "Color Theory Guide",
                description: "Visual guide to understanding color relationships",
                type: .art,
                category: "Education",
                rating: 5,
                imageName: "eyedropper"
            )
        ]
        
        mediaItems = sampleMediaItems
        
        // Create sample playlists
        let creativePalette = Playlist(
            name: "Creative Palette",
            description: "Curated content for creative inspiration",
            colorTheme: "#ffc934"
        )
        
        let focusCollection = Playlist(
            name: "Focus Collection",
            description: "Media for deep work and concentration",
            colorTheme: "#ae2d27"
        )
        
        playlists = [creativePalette, focusCollection]
        saveData()
    }
} 