
import CoreLocation
import Foundation
import GRDB

public extension TrackPointInterface {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Input

/*
 public class TrackPoint: Record, TableCreator, TrackPointInterface,  CustomStringConvertible {

     public var id: String = UUID().uuidString
     public var latitude: Double
     public var longitude: Double
     public var elevation: Double
     public var horizontalAccuracy: Double
     public var speed: Double
     public var speedAccuracy: Double
     public var course: Double
     public var courseAccuracy: Double
     public var timestamp: Date
     public var trackId: String? = nil

 }
 */

// MARK: - EndInput

// protocol
public protocol TrackPointInterface {
    var id: String { get set }
    var latitude: Double { get set }
    var longitude: Double { get set }
    var elevation: Double { get set }
    var horizontalAccuracy: Double { get set }
    var speed: Double { get set }
    var speedAccuracy: Double { get set }
    var course: Double { get set }
    var courseAccuracy: Double { get set }
    var timestamp: Date { get set }
    var trackId: String? { get set }
}

public class TrackPoint: Record, TableCreator, TrackPointInterface, Equatable, CustomStringConvertible {
    public var description: String {
        "\(latitude), \(longitude) - \(id) \(trackId ?? "")"
    }

    public var id: String
    public var latitude: Double
    public var longitude: Double
    public var elevation: Double
    public var horizontalAccuracy: Double
    public var speed: Double
    public var speedAccuracy: Double
    public var course: Double
    public var courseAccuracy: Double
    public var timestamp: Date
    public var trackId: String?

    public init(
        id: String = UUID().uuidString,
        latitude: Double,
        longitude: Double,
        elevation: Double,
        horizontalAccuracy: Double,
        speed: Double,
        speedAccuracy: Double,
        course: Double,
        courseAccuracy: Double,
        timestamp: Date,
        trackId: String? = nil
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.horizontalAccuracy = horizontalAccuracy
        self.speed = speed
        self.speedAccuracy = speedAccuracy
        self.course = course
        self.courseAccuracy = courseAccuracy
        self.timestamp = timestamp
        self.trackId = trackId
        super.init()
    }

    // protocol based initializer
    public init(from: TrackPointInterface) {
        id = from.id
        latitude = from.latitude
        longitude = from.longitude
        elevation = from.elevation
        horizontalAccuracy = from.horizontalAccuracy
        speed = from.speed
        speedAccuracy = from.speedAccuracy
        course = from.course
        courseAccuracy = from.courseAccuracy
        timestamp = from.timestamp
        trackId = from.trackId
        super.init()
    }

    public func toSwift() -> String {
        """
        TrackPoint(
            id: "\(id)",
            latitude: \(latitude),
            longitude: \(longitude),
            elevation: \(elevation),
            horizontalAccuracy: \(horizontalAccuracy),
            speed: \(speed),
            speedAccuracy: \(speedAccuracy),
            course: \(course),
            courseAccuracy: \(courseAccuracy),
            timestamp:  Date(timeIntervalSince1970: \(timestamp.timeIntervalSince1970)),
            trackId: \(trackId != nil ? "\"\(trackId!)\"" : "nil")
            )
        """
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(latitude)
        hasher.combine(longitude)
        hasher.combine(elevation)
        hasher.combine(horizontalAccuracy)
        hasher.combine(speed)
        hasher.combine(speedAccuracy)
        hasher.combine(course)
        hasher.combine(courseAccuracy)
        hasher.combine(timestamp)
        hasher.combine(trackId)
    }

    public static func == (lhs: TrackPoint, rhs: TrackPoint) -> Bool {
        lhs.id == rhs.id &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude &&
            lhs.elevation == rhs.elevation &&

            lhs.timestamp == rhs.timestamp &&
            lhs.trackId == rhs.trackId
    }

    public func updated(
        id: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        elevation: Double? = nil,
        horizontalAccuracy: Double? = nil,
        speed: Double? = nil,
        speedAccuracy: Double? = nil,
        course: Double? = nil,
        courseAccuracy: Double? = nil,
        timestamp: Date? = nil,
        trackId: String? = nil
    ) -> TrackPoint {
        TrackPoint(
            id: id ?? self.id,
            latitude: latitude ?? self.latitude,
            longitude: longitude ?? self.longitude,
            elevation: elevation ?? self.elevation,
            horizontalAccuracy: horizontalAccuracy ?? self.horizontalAccuracy,
            speed: speed ?? self.speed,
            speedAccuracy: speedAccuracy ?? self.speedAccuracy,
            course: course ?? self.course,
            courseAccuracy: courseAccuracy ?? self.courseAccuracy,
            timestamp: timestamp ?? self.timestamp,
            trackId: trackId ?? self.trackId
        )
    }

    // MARK: - GRDB.Record

    /// The table name
    override public class var databaseTableName: String { "TrackPoint_table" }

    /// The table columns
    enum Columns: String, ColumnExpression {
        case id
        case latitude
        case longitude
        case elevation
        case horizontalAccuracy
        case speed
        case speedAccuracy
        case course
        case courseAccuracy
        case timestamp
        case trackId
    }

    /// Creates a record from a database row
    required init(row: Row) {
        id = row[Columns.id]
        latitude = row[Columns.latitude]
        longitude = row[Columns.longitude]
        elevation = row[Columns.elevation]
        horizontalAccuracy = row[Columns.horizontalAccuracy]
        speed = row[Columns.speed]
        speedAccuracy = row[Columns.speedAccuracy]
        course = row[Columns.course]
        courseAccuracy = row[Columns.courseAccuracy]
        timestamp = row[Columns.timestamp]
        trackId = row[Columns.trackId]
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.latitude] = latitude
        container[Columns.longitude] = longitude
        container[Columns.elevation] = elevation
        container[Columns.horizontalAccuracy] = horizontalAccuracy
        container[Columns.speed] = speed
        container[Columns.speedAccuracy] = speedAccuracy
        container[Columns.course] = course
        container[Columns.courseAccuracy] = courseAccuracy
        container[Columns.timestamp] = timestamp
        container[Columns.trackId] = trackId
    }

    // MARK: - Table Creation

    class func createTable(db: Database) throws {
        try db.create(table: databaseTableName) { t in
            t.primaryKey(["id"])
            t.column("id", .text)
            t.column("latitude", .double)
            t.column("longitude", .double)
            t.column("elevation", .double)
            t.column("horizontalAccuracy", .double)
            t.column("speed", .double)
            t.column("speedAccuracy", .double)
            t.column("course", .double)
            t.column("courseAccuracy", .double)
            t.column("timestamp", .datetime)
            t.column("trackId", .text)
        }
    }
}
