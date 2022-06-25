//
//  Music.swift
//  
//
//  Created by Nicholas Trienens on 6/20/22.
//

import Foundation
import MusadoraKit
import MusicKit
import DependencyContainer

public typealias Playlists = MusicItemCollection<Playlist>

public extension ContainerKeys {
    static let music = KeyedDependency("Music", type: Music.self)
}
public actor Music {
    
    public static let shared = Music()
    
    public init() {
        
    }
    
    public func search(_ query: String) async throws -> MusicItemCollection<Song> {
        let _ = await MusicAuthorization.request()
        let searchResponse = try await MusadoraKit.librarySearch(for: query, types: [Song.self])
        return searchResponse.songs
    }
    
    public func playlists() async throws -> MusicItemCollection<Playlist> {
        let _ = await MusicAuthorization.request()

        let playLists = try await MusadoraKit.libraryPlaylists()
        osLog(playLists.hasNextBatch)
        
        osLog( try await playLists.last?.catalog)
        
        
        if let first = playLists.last {
            let rptracks = try await MusadoraKit.recentlyPlayedTracks()
            osLog(rptracks)
            //let tracks = try await first.catalog
            let ptrack = try await MusadoraKit.libraryPlaylist(id: first.id)
            
            osLog(ptrack.kind)
            osLog(first)
            osLog(ptrack.tracks)
        }
        osLog(playLists)
        return playLists
    }
}
