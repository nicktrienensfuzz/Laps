//
//  CircularPOI.swift
//
//
//  Created by Nicholas Trienens on 7/22/22.
//

import CoreLocation
import Foundation
import GRDB
import MapKit
import OrderedCollections

public extension CircularPOIInterface {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var circle: MKCircle {
        MKCircle(center: coordinate, radius: radius)
    }
}

extension CircularPOI: CustomStringConvertible {
    public var description: String {
        "\(id) \(radius) \(trackId ?? "na")"
    }
}

// MARK: - Input

/*
 public class CircularPOI: Record, CircularPOIInterface, Equatable, TableCreator {

     public var id: String = UUID().uuidString
     public var latitude: Double
     public var longitude: Double
     public var radius: Double
     public var trackId: String? = nil
     public var timestamp: Date
     public var test: Date
     public let enteredAt: Date? = nil

 }
 */

// MARK: - EndInput

// protocol
public protocol CircularPOIInterface {
    var id: String { get set }
    var latitude: Double { get set }
    var longitude: Double { get set }
    var radius: Double { get set }
    var trackId: String? { get set }
    var timestamp: Date { get set }
    var enteredAt: Date? { get set }
}

public class CircularPOI: Record, CircularPOIInterface, Equatable, TableCreator {
    public var id: String
    public var latitude: Double
    public var longitude: Double
    public var radius: Double
    public var trackId: String?
    public var timestamp: Date
    public var enteredAt: Date?

    public init(
        id: String = UUID().uuidString,
        latitude: Double,
        longitude: Double,
        radius: Double,
        trackId: String? = nil,
        timestamp: Date,
        enteredAt: Date? = nil
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.trackId = trackId
        self.timestamp = timestamp
        self.enteredAt = enteredAt
        super.init()
    }

    // protocol based initializer
    public init(from: CircularPOIInterface) {
        id = from.id
        latitude = from.latitude
        longitude = from.longitude
        radius = from.radius
        trackId = from.trackId
        timestamp = from.timestamp
        enteredAt = from.enteredAt
        super.init()
    }

    public func toSwift() -> String {
        """
        CircularPOI(
            id: "\(id)"
            ,
            latitude: \(latitude),
            longitude: \(longitude),
            radius: \(radius),
            trackId: \(trackId != nil ? "\"\(trackId!)\"" : "nil")
            ,
            timestamp:  Date(timeIntervalSince1970: \(timestamp.timeIntervalSince1970))
            ,
            enteredAt:  \(enteredAt != nil ? "Date(timeIntervalSince1970: \(enteredAt!.timeIntervalSince1970))" : "nil")
            )
        """
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(latitude)
        hasher.combine(longitude)
        hasher.combine(radius)
        hasher.combine(trackId)
        hasher.combine(timestamp)
        hasher.combine(enteredAt)
    }

    public static func == (lhs: CircularPOI, rhs: CircularPOI) -> Bool {
        lhs.id == rhs.id &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude &&
            lhs.radius == rhs.radius &&
            lhs.trackId == rhs.trackId &&
            lhs.timestamp == rhs.timestamp &&
            lhs.enteredAt == rhs.enteredAt
    }

    public var attributes: OrderedDictionary<String, WritableKeyPath<CircularPOI, String>> {
        [
            "id": \CircularPOI.id,
        ]
    }

    public func updated(
        id: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        radius: Double? = nil,
        trackId: String? = nil,
        timestamp: Date? = nil,
        enteredAt: Date? = nil
    ) -> CircularPOI {
        CircularPOI(
            id: id ?? self.id,
            latitude: latitude ?? self.latitude,
            longitude: longitude ?? self.longitude,
            radius: radius ?? self.radius,
            trackId: trackId ?? self.trackId,
            timestamp: timestamp ?? self.timestamp,
            enteredAt: enteredAt ?? self.enteredAt
        )
    }

    // MARK: - GRDB.Record

    /// The table name
    override public class var databaseTableName: String { "CircularPOI_table" }

    /// The table columns
    enum Columns: String, ColumnExpression {
        case id
        case latitude
        case longitude
        case radius
        case trackId
        case timestamp
        case enteredAt
    }

    /// Creates a record from a database row
    required init(row: Row) {
        id = row[Columns.id]
        latitude = row[Columns.latitude]
        longitude = row[Columns.longitude]
        radius = row[Columns.radius]
        trackId = row[Columns.trackId]
        timestamp = row[Columns.timestamp]
        enteredAt = row[Columns.enteredAt]
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.latitude] = latitude
        container[Columns.longitude] = longitude
        container[Columns.radius] = radius
        container[Columns.trackId] = trackId
        container[Columns.timestamp] = timestamp
        container[Columns.enteredAt] = enteredAt
    }

    // MARK: - Table Creation

    class func createTable(db: Database) throws {
        try db.create(table: databaseTableName) { t in
            t.primaryKey(["id"])
            t.column("id", .text)
            t.column("latitude", .double)
            t.column("longitude", .double)
            t.column("radius", .double)
            t.column("trackId", .text)
            t.column("timestamp", .datetime)
            t.column("enteredAt", .text)
        }
    }
}
