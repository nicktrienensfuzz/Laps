
import Foundation
import GRDB
import MusadoraKit
import MusicKit
import OrderedCollections
import TuvaCore

public extension PlaylistRecord {
    func playlistWithTracks() async throws -> Playlist {
        var detailedPlaylist = try await Music.shared.playlist(id: id)
        detailedPlaylist = try await detailedPlaylist.with([.tracks])
        return detailedPlaylist
    }
//    func playlistWithTracks() async throws -> Playlist? {
//        var detailedPlaylist = try await Music.shared.playlist(id: id)
//        detailedPlaylist = try await detailedPlaylist.with([.tracks])
//        return detailedPlaylist
//    }
}

// MARK: - Input

/*
 public class PlaylistRecord: Record, TableCreator, PlaylistRecordInterface, Equatable {
     public var id: String = UUID().uuidString
     public var name: String
     public var tracks: Int
     public var selected: Bool? = nil
     public var timestamp: Date
 }
 */

// MARK: - EndInput

// protocol
public protocol PlaylistRecordInterface {
    var id: String { get set }
    var name: String { get set }
    var tracks: Int { get set }
    var selected: Bool? { get set }
    var timestamp: Date { get set }
}

public class PlaylistRecord: Record, TableCreator, PlaylistRecordInterface, Equatable, Identifiable, CustomStringConvertible {
    public var description: String {
        toSwift()
    }

    public var id: String
    public var name: String
    public var tracks: Int
    public var selected: Bool?
    public var timestamp: Date

    public init(
        id: String = UUID().uuidString,
        name: String,
        tracks: Int,
        selected: Bool? = nil,
        timestamp: Date
    ) {
        self.id = id
        self.name = name
        self.tracks = tracks
        self.selected = selected
        self.timestamp = timestamp
        super.init()
    }

    // protocol based initializer
    public init(from: PlaylistRecordInterface) {
        id = from.id
        name = from.name
        tracks = from.tracks
        selected = from.selected
        timestamp = from.timestamp
        super.init()
    }

    public func toSwift() -> String {
        """
        PlaylistRecord(
            id: "\(id)",
            name: "\(name)",
            tracks: \(tracks),
            selected: \(selected != nil ? "\(selected!)" : "nil"),
            timestamp:  Date(timeIntervalSince1970: \(timestamp.timeIntervalSince1970))
            )
        """
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(tracks)
        hasher.combine(selected)
        hasher.combine(timestamp)
    }

    public static func == (lhs: PlaylistRecord, rhs: PlaylistRecord) -> Bool {
        lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.tracks == rhs.tracks &&
            lhs.selected == rhs.selected &&
            lhs.timestamp == rhs.timestamp
    }

    public var attributes: OrderedDictionary<String, WritableKeyPath<PlaylistRecord, String>> {
        [
            "id": \PlaylistRecord.id,
            "name": \PlaylistRecord.name,
        ]
    }

    public func updated(
        id: String? = nil,
        name: String? = nil,
        tracks: Int? = nil,
        selected: Bool? = nil,
        timestamp: Date? = nil
    ) -> PlaylistRecord {
        PlaylistRecord(
            id: id ?? self.id,
            name: name ?? self.name,
            tracks: tracks ?? self.tracks,
            selected: selected ?? self.selected,
            timestamp: timestamp ?? self.timestamp
        )
    }

    // MARK: - GRDB.Record

    /// The table name
    override public class var databaseTableName: String { "PlaylistRecord_table" }

    /// The table columns
    enum Columns: String, ColumnExpression {
        case id
        case name
        case tracks
        case selected
        case timestamp
    }

    /// Creates a record from a database row
    required init(row: Row) {
        id = row[Columns.id]
        name = row[Columns.name]
        tracks = row[Columns.tracks]
        selected = row[Columns.selected]
        timestamp = row[Columns.timestamp]
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.tracks] = tracks
        container[Columns.selected] = selected
        container[Columns.timestamp] = timestamp
    }

    // MARK: - Table Creation

    class func createTable(db: Database) throws {
        try db.create(table: databaseTableName) { t in
            t.primaryKey(["id"])
            t.column("id", .text)
            t.column("name", .text)
            t.column("tracks", .integer)
            t.column("selected", .text)
            t.column("timestamp", .datetime)
        }
    }
}
