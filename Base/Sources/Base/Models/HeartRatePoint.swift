
import Foundation
import GRDB
import OrderedCollections

// MARK: - Input

/*
 public class HeartRatePoint: Record, TableCreator, HeartRatePointInterface {

     public var id: String = UUID().uuidString
     public var timestamp: Date = Date()
     public var heartRate: Double
     public var trackId: String? = nil

 }
 */

// MARK: - EndInput

// protocol
public protocol HeartRatePointInterface {
    var id: String { get set }
    var timestamp: Date { get set }
    var heartRate: Double { get set }
    var trackId: String? { get set }
}

public class HeartRatePoint: Record, TableCreator, HeartRatePointInterface, Equatable {
    public var id: String
    public var timestamp: Date
    public var heartRate: Double
    public var trackId: String?

    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        heartRate: Double,
        trackId: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.heartRate = heartRate
        self.trackId = trackId
        super.init()
    }

    // protocol based initializer
    public init(from: HeartRatePointInterface) {
        id = from.id
        timestamp = from.timestamp
        heartRate = from.heartRate
        trackId = from.trackId
        super.init()
    }

    public func toSwift() -> String {
        """
        HeartRatePoint(
            id: "\(id)",
            timestamp:  Date(timeIntervalSince1970: \(timestamp.timeIntervalSince1970)),
            heartRate: \(heartRate),
            trackId: \(trackId != nil ? "\"\(trackId!)\"" : "nil")
            )
        """
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(timestamp)
        hasher.combine(heartRate)
        hasher.combine(trackId)
    }

    public static func == (lhs: HeartRatePoint, rhs: HeartRatePoint) -> Bool {
        lhs.id == rhs.id &&
            lhs.timestamp == rhs.timestamp &&
            lhs.heartRate == rhs.heartRate &&
            lhs.trackId == rhs.trackId
    }

    public func updated(
        id: String? = nil,
        timestamp: Date? = nil,
        heartRate: Double? = nil,
        trackId: String? = nil
    ) -> HeartRatePoint {
        HeartRatePoint(
            id: id ?? self.id,
            timestamp: timestamp ?? self.timestamp,
            heartRate: heartRate ?? self.heartRate,
            trackId: trackId ?? self.trackId
        )
    }

    // MARK: - GRDB.Record

    /// The table name
    override public class var databaseTableName: String { "HeartRatePoint_table" }

    /// The table columns
    enum Columns: String, ColumnExpression {
        case id
        case timestamp
        case heartRate
        case trackId
    }

    /// Creates a record from a database row
    required init(row: Row) {
        id = row[Columns.id]
        timestamp = row[Columns.timestamp]
        heartRate = row[Columns.heartRate]
        trackId = row[Columns.trackId]
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.timestamp] = timestamp
        container[Columns.heartRate] = heartRate
        container[Columns.trackId] = trackId
    }

    // MARK: - Table Creation

    class func createTable(db: Database) throws {
        try db.create(table: databaseTableName) { t in
            t.primaryKey(["id"])
            t.column("id", .text)
            t.column("timestamp", .datetime)
            t.column("heartRate", .double)
            t.column("trackId", .text)
        }
    }
}
