//
//  Track.swift
//
//
//  Created by Nicholas Trienens on 6/22/22.
//

import Combine
import DependencyContainer
import Foundation
import GRDB

// protocol
public protocol TrackInterface {
    var id: String { get }
    var startTime: Date { get }
    var endTime: Date? { get }
    var name: String? { get }
}

public class Track: GRDB.Record, TableCreator, TrackInterface, Equatable {
    public static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }

    public let id: String
    public let startTime: Date
    public let endTime: Date?
    public let name: String?

    public var live: Bool {
        true
    }

    public init(
        id: String = UUID().uuidString,
        startTime: Date,
        endTime: Date? = nil,
        name: String? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.name = name
        super.init()
    }

    // protocol based initializer
    public init(from: TrackInterface) {
        id = from.id
        startTime = from.startTime
        endTime = from.endTime
        name = from.name
        super.init()
    }

    public func toSwift() -> String {
        """
        Track(
            id: "\(id)"
            ,
            startTime:  Date(timeIntervalSince1970: \(startTime.timeIntervalSince1970))
            ,
            endTime:  \(endTime != nil ? "Date(timeIntervalSince1970: \(endTime!.timeIntervalSince1970))" : "nil")
            ,
            name: \(name != nil ? "\"\(name!)\"" : "nil")
            )
        """
    }

    public func updated(
        id: String? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        name: String? = nil
    ) -> Track {
        Track(
            id: id ?? self.id,
            startTime: startTime ?? self.startTime,
            endTime: endTime ?? self.endTime,
            name: name ?? self.name
        )
    }

    // MARK: - GRDB.Record

    /// The table name
    override public class var databaseTableName: String { "Track_table" }

    /// The table columns
    enum Columns: String, ColumnExpression {
        case id
        case startTime
        case endTime
        case name
    }

    /// Creates a record from a database row
    required init(row: Row) {
        id = row[Columns.id]
        startTime = row[Columns.startTime]
        endTime = row[Columns.endTime]
        name = row[Columns.name]
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.startTime] = startTime
        container[Columns.endTime] = endTime
        container[Columns.name] = name
    }

    // MARK: - Table Creation

    class func createTable(db: Database) throws {
        try db.create(table: databaseTableName) { t in
            t.primaryKey(["id"])
            t.column("id", .text)
            t.column("startTime", .datetime)
            t.column("endTime", .text)
            t.column("name", .text)
        }
    }
}

public extension Track {
    var points: AnyPublisher<[TrackPoint], Never> {
        let query = TrackPoint.filter(sql: "trackId = '\(id)'")

        return try! DependencyContainer.resolve(key: ContainerKeys.database)
            .observeAll(query)
            .catch { error -> AnyPublisher<[TrackPoint], Never> in
                osLog(error)
                return Just.any([TrackPoint]())
            }
            .eraseToAnyPublisher()
    }
}
