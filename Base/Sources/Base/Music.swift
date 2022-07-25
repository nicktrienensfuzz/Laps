//
//  Music.swift
//
//
//  Created by Nicholas Trienens on 6/20/22.
//

import Combine
import DependencyContainer
import Drops
import Foundation
import GRDB
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

    public init() {}

    public func play(playParameters: PlayParameters) async throws {
        let playParameters = try playParameters.toMPPlayParameters()
        let queue = MPMusicPlayerPlayParametersQueueDescriptor(playParametersQueue: [playParameters])

        let player = MPMusicPlayerController.systemMusicPlayer

        /// Set the queue
        player.setQueue(with: queue)
        try await player.prepareToPlay()

        /// Finally, play the album!
        player.play()
    }

    public func play(playParameters: [PlayParameters]) async throws {
        let playParameters = try playParameters.map { try $0.toMPPlayParameters() }
        let queue = MPMusicPlayerPlayParametersQueueDescriptor(playParametersQueue: playParameters)

        let player = MPMusicPlayerController.systemMusicPlayer

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

//    public func search(_ query: String) async throws -> MusicItemCollection<Song> {
//        _ = await MusicAuthorization.request()
//        let searchResponse = try await MusadoraKit.librarySearch(for: query, types: [Song.self])
//        return searchResponse.songs
//    }

    public func observablePlaylists() -> AnyPublisher<[PlaylistRecord], Never> {
        try! DependencyContainer.resolve(key: ContainerKeys.database)
            .observeAll(
                PlaylistRecord.all()
                    .order(PlaylistRecord.Columns.name)
                    .limit(10)
            )
            .catch { error -> AnyPublisher<[PlaylistRecord], Never> in
                osLog(error)
                return Just.any([PlaylistRecord]())
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func favorite(_ playlist: PlaylistRecord) async throws {
        try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db in

            for p in try PlaylistRecord.fetchAll(db) {
                p.selected = false
                try p.save(db)
            }

            playlist.selected = true
            try playlist.save(db)
        }
    }

    public func playlist(id: String) async throws -> Playlist {
        _ = await MusicAuthorization.request()
        let playlists = try await MusadoraKit.libraryPlaylists(ids: [MusicItemID(id)])
        return try playlists.first.unwrapped("no playlists found")
    }

    public func playlists() async throws -> MusicItemCollection<Playlist> {
        _ = await MusicAuthorization.request()

        let playLists = try await MusadoraKit.libraryPlaylists()
        Task {
            try? await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db in
                for playlist in playLists {
                    if let existing = try PlaylistRecord.fetchOne(db, id: playlist.id.rawValue) {
                        existing.name = playlist.name
                        existing.timestamp = playlist.lastModifiedDate ?? existing.timestamp
                        try existing.save(db)
                    } else {
                        let newPlaylist = PlaylistRecord(id: playlist.id.rawValue,
                                                         name: playlist.name,
                                                         tracks: 0,
                                                         selected: nil,
                                                         timestamp: playlist.lastModifiedDate ?? .now)

                        try newPlaylist.save(db)
                    }
                }
            }
        }
        return playLists
    }

    var track: MusicKit.Track?

    public func isPlaying() -> Bool {
        let player = MPMusicPlayerController.systemMusicPlayer
        osLog(player.playbackState.asString)
        return player.playbackState == .playing
    }

    public func test() async {
        _ = await MusicAuthorization.request()

        do {
            Drops.show(.init(title: "playing"))
            // try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.read

            let selected = try await DependencyContainer.resolve(key: ContainerKeys.database).dbPool.write { db -> PlaylistRecord? in
                try PlaylistRecord.fetchOne(db, PlaylistRecord.all().filter(PlaylistRecord.Columns.selected == true)) // ?? try PlaylistRecord.fetchOne(db)
            }

            if let selected = selected, let playlist = try await selected.playlistWithTracks() {
                Drops.show(.init(title: "playing: \(selected.name)"))
                if let t = playlist.tracks?.compactMap(\.playParameters) {
                    osLog(t)
                    // try await Music.shared.play(playParameters: t)
                }
            }
//
//            /// First request to get the heavy rotation albums
//            let rptracks = try await MusadoraKit.recentlyPlayedTracks()
//            track = rptracks.randomElement()
//            // osLog(rptracks)
//            if let userItem = track {
//                if let playParameters = userItem.playParameters {
//                    try await play(playParameters: playParameters)
//
//                    return
//                }
//            }
//
//            let playLists = try await MusadoraKit.libraryPlaylists()
//            if let first = playLists.last, let mkPlayParameters: PlayParameters = first.playParameters {
//                try await play(playParameters: mkPlayParameters)
//                return
//            }

        } catch {
            osLog(error)
        }
    }
}

public extension MPMusicPlaybackState {
    var asString: String {
        switch self {
        case .stopped:
            return "stopped"
        case .playing:
            return "playing"
        case .paused:
            return "paused"
        case .interrupted:
            return "interrupted"
        case .seekingForward:
            return "seekingForward"
        case .seekingBackward:
            return "seekingBackward"
        @unknown default:
            return "@unknown"
        }
    }
}
