
import Foundation
import GRDB
import CoreLocation

extension TrackPointInterface {
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// protocol
public protocol TrackPointInterface {
    
    var id: String { get }
    var latitude: Double { get }
    var longitude: Double { get }
    var timestamp: Date { get }
    var trackId: String? { get }
}
public class TrackPoint: Record, TableCreator, TrackPointInterface, CustomStringConvertible {
    
    public let id: String
    public let latitude: Double
    public let longitude: Double
    public let timestamp: Date
    public let trackId: String?

    public var description: String {
        "\(latitude), \(longitude) - \(id) \(trackId ?? "")"
    }
    
    
    public init(
        id: String = UUID().uuidString,
        latitude: Double,
        longitude: Double,
        timestamp: Date,
        trackId: String? = nil
    ){
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.trackId = trackId
                super.init()
    }
    // protocol based initializer
    public init(from: TrackPointInterface){
        self.id = from.id
        self.latitude = from.latitude
        self.longitude = from.longitude
        self.timestamp = from.timestamp
        self.trackId = from.trackId
        super.init()
    }
    
    

    public func toSwift() -> String {
            """
            TrackPoint(
                id: "\(id)"
                ,
                latitude: \(latitude),
                longitude: \(longitude),
                timestamp:  Date(timeIntervalSince1970: \(timestamp.timeIntervalSince1970))
                ,
                trackId: \(trackId != nil ? "\"\(trackId!)\"" : "nil")
                )
            """
    }
    

                
        public func updated(
            id: String? = nil,
            latitude: Double? = nil,
            longitude: Double? = nil,
            timestamp: Date? = nil,
            trackId: String? = nil
        ) -> TrackPoint {
            return TrackPoint(
                id: id ?? self.id,
                latitude: latitude ?? self.latitude,
                longitude: longitude ?? self.longitude,
                timestamp: timestamp ?? self.timestamp,
                trackId: trackId ?? self.trackId)
                
            
        }
        
    



    // MARK: - GRDB.Record
    /// The table name
    override public class var databaseTableName: String { "TrackPoint_table" }

    /// The table columns
    enum Columns: String, ColumnExpression {
        case id
        case latitude
        case longitude
        case timestamp
        case trackId
    }

    /// Creates a record from a database row
    required init(row: Row) {
        id = row[Columns.id]
        latitude = row[Columns.latitude]
        longitude = row[Columns.longitude]
        timestamp = row[Columns.timestamp]
        trackId = row[Columns.trackId]
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.latitude] = latitude
        container[Columns.longitude] = longitude
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
            t.column("timestamp", .datetime)
            t.column("trackId", .text)
        }
    }

}
