//
//  Music.swift
//
//
//  Created by Nicholas Trienens on 6/20/22.
//

import DependencyContainer
import Foundation
import MediaPlayer
import MusadoraKit
import MusicKit

public typealias Playlists = MusicItemCollection<Playlist>

public extension ContainerKeys {
    static let music = KeyedDependency("Music", type: Music.self)
}

extension PlayParameters {
    func toMPPlayParameters() throws -> MPMusicPlayerPlayParameters {
        /// Encode the parameters
        let data = try JSONEncoder().encode(self)

        /// Decode the parameters to `MPMusicPlayerPlayParameters`
        let playParameters: MPMusicPlayerPlayParameters = try JSONDecoder().decode(MPMusicPlayerPlayParameters.self, from: data)

        return playParameters
    }
}

public actor Music {
    public static let shared = Music()

    public init() {
        
    }

    public func play(playParameters: PlayParameters) async throws {
        let playParameters = try playParameters.toMPPlayParameters()
        let queue = MPMusicPlayerPlayParametersQueueDescriptor(playParametersQueue: [playParameters])

        let player = MPMusicPlayerController.applicationMusicPlayer

        /// Set the queue
        player.setQueue(with: queue)
        try await player.prepareToPlay()

        /// Finally, play the album!
        player.play()
    }

    public func play(playParameters: MPMusicPlayerPlayParameters) async throws {
        let queue = MPMusicPlayerPlayParametersQueueDescriptor(playParametersQueue: [playParameters])

        let player = MPMusicPlayerController.systemMusicPlayer

        /// Set the queue
        player.setQueue(with: queue)
        try await player.prepareToPlay()

        /// Finally, play the album!
        player.play()
    }

    public func search(_ query: String) async throws -> MusicItemCollection<Song> {
        _ = await MusicAuthorization.request()
        let searchResponse = try await MusadoraKit.librarySearch(for: query, types: [Song.self])
        return searchResponse.songs
    }

    public func playlists() async throws -> MusicItemCollection<Playlist> {
        _ = await MusicAuthorization.request()

        let playLists = try await MusadoraKit.libraryPlaylists()
        // osLog(playLists.hasNextBatch)

        // osLog( try await playLists.last?.catalog)

        if let first = playLists.last {
            // let tracks = try await first.catalog
            // let ptrack = try await MusadoraKit.libraryPlaylist(id: first.id)

            osLog(first.kind)
            osLog(first)
            osLog(first.tracks)
        }
        osLog(playLists)
        return playLists
    }

    public func test() async {
        do {
            /// First request to get the heavy rotation albums
            let rptracks = try await MusadoraKit.recentlyPlayed()
            // osLog(rptracks)
            if let userItem = rptracks.randomElement() {
                switch userItem {
                case let .station(station):
                    osLog(station)
                    if let playParameters = station.playParameters {
                        try await play(playParameters: playParameters)

                        return
                    }
                default: osLog("nope")
                }
            }

            let playLists = try await MusadoraKit.libraryPlaylists()
            if let first = playLists.last, let mkPlayParameters: PlayParameters = first.playParameters {
                try await play(playParameters: mkPlayParameters)
                return
            }

//            guard let url = URL(string: "https://api.music.apple.com/v1/me/") else { return }
//
//            osLog("Making request")
//
//            let request = MusicDataRequest(urlRequest: URLRequest(url: url))
//            let response = try await request.response()
//            osLog("Decoding")
//            let heavyRotationAlbums = try JSONDecoder().decode(MusicItemCollection<Album>.self, from: response.data)
//            osLog("Decoded")
//            osLog("Decoding: count \(response.data.count)")
//            osLog(String( data:response.data, encoding: .utf8))
//            /// Get the first album
//            guard let album = heavyRotationAlbums.first else {
//                osLog("no album ")
//                return
//
//            }
//            osLog("Got an Album")
//            osLog(album)
//            /// Get the local album ID
//            let albumID = album.id
//
//            osLog("Making request")
//            /// Another request to get the album from Apple Music Catalog
//            guard let catalogURL = URL(string: "https://api.music.apple.com/v1/me/library/albums/\(albumID)/catalog") else {
//                osLog("no url ")
//                return }
//
//            let catalogRequest = MusicDataRequest(urlRequest: URLRequest(url: catalogURL))
//            let catalogResponse = try await catalogRequest.response()
//            osLog("Decoding: count \(catalogResponse.data.count)")
//            osLog(String( data:catalogResponse.data, encoding: .utf8))
//            let albums = try JSONDecoder().decode(MusicItemCollection<Album>.self, from: catalogResponse.data)
//
//            /// Get the same album, but with the catalog ID
//            guard let catalogAlbum = albums.first else { return }
//
//            /// Encode the parameters
//            let data = try JSONEncoder().encode(catalogAlbum.playParameters)
//
//            /// Decode the parameters to `MPMusicPlayerPlayParameters`
//            let playParameters = try JSONDecoder().decode(MPMusicPlayerPlayParameters.self, from: data)
//
//            // Create the queue
//            let queue = MPMusicPlayerPlayParametersQueueDescriptor(playParametersQueue: [playParameters])
//
//            let player = MPMusicPlayerController.applicationMusicPlayer
//
//            /// Set the queue
//            player.setQueue(with: queue)
//            try await player.prepareToPlay()
//
//            /// Finally, play the album!
//            player.play()
        } catch {
            osLog(error)
        }
    }
}
