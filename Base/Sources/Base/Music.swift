//
//  Music.swift
//  
//
//  Created by Nicholas Trienens on 6/20/22.
//

import Foundation
import MusadoraKit
import MusicKit

public typealias Playlists = MusicItemCollection<Playlist>

public actor Music {
    
    public static let shared = Music()
    
    public init() {
        
    }
    
    public func search(_ query: String) async throws -> [Song] {
        let _ = await MusicAuthorization.request()
        let searchResponse = try await MusadoraKit.librarySearch(for: query, types: [Song.self])
        let playLists = try await MusadoraKit.libraryPlaylists()
        
        
        print(playLists)
        return searchResponse.songs.reversed().reversed()
    }
    public func playlists() async throws -> MusicItemCollection<Playlist> {
        let _ = await MusicAuthorization.request()

        let playLists = try await MusadoraKit.libraryPlaylists()
        
        print(playLists)
        return playLists
    }
}
