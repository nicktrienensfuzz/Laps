
import Combine
import DependencyContainer
import Foundation
import FuzzCombine
import GRDB

public extension ContainerKeys {
    static let database = KeyedDependency("database", type: AppDatabaseInterface.self)

}

public typealias ValueObservation = GRDB.ValueObservation
public typealias Column = GRDB.Column

class AppDatabase: AppDatabaseInterface, AppDatabaseSynchronousInterface {
    static let schemaVersion = 2
    var tableList: [TableCreator.Type] {
        [
            TrackPoint.self,
            Track.self
        ]
    }

    let state = CurrentValueSubject<AppDatabaseState, Never>(.notStarted)
    public let dbPool: DatabaseWriter
    let currentDBPath: URL
    /// inUrl is mostly used for testing.
    init(_ inUrl: String? = nil, _ configuration: GRDB.Configuration = GRDB.Configuration()) {
        do {
            if let inUrl = inUrl {
                dbPool = try DatabasePool(path: inUrl, configuration: configuration)
                state.value = .ready
                currentDBPath = URL(fileURLWithPath: inUrl)
//                do {
//                    try dbPool.read { db in
//                        let dbHasData = try UserRecord.fetchCount(db)
//                        osLog(dbHasData)
//                    }
//                } catch {
//                    state.value = .opened
                try configure()
                // }
            } else {
                let fileManager = FileManager()
                let folderURL = try fileManager
                    .url(
                        for: .cachesDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: false
                    )
                    .appendingPathComponent("database", isDirectory: true)

                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)

                let dbURL = folderURL.appendingPathComponent("db-\(Self.schemaVersion).sqlite")
                currentDBPath = dbURL

                dbPool = try DatabasePool(path: dbURL.path)
                state.value = .opened
                try configure()
            }

        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            //
            // Typical reasons for an error here include:
            // * The parent directory cannot be created, or disallows writing.
            // * The database is not accessible, due to permissions or data protection when the device is locked.
            // * The device is out of space.
            // * The database could not be migrated to its latest schema version.
            // Check the error message to determine what the actual problem was.
            state.value = .fileError(error)
            fatalError("Unresolved error \(error)")
        }
    }

    func configure() throws {
        guard state.value == .opened else {
            osLog("\(state.value)")
            osLog("Already Configured Database")
            return
        }
        var migrator = DatabaseMigrator()
        // Speed up development by nuking the database when migrations change
        // migrator.eraseDatabaseOnSchemaChange = true

        #if DEBUG
            // Speed up development by nuking the database
            // when migrations change
            migrator.eraseDatabaseOnSchemaChange = true
        #endif
        tableList.forEach { t in
            osLog("Queuing Migration: \(t.databaseTableName)")
            migrator.registerMigration("create table: " + t.databaseTableName) { db in
                osLog("running migration \(t.databaseTableName)")
                do {
                    try t.createTable(db: db)
                } catch {
                    osLog("\(error)")
                    throw DatabaseError("Failed to create table \(t)")
                }
            }
        }
        do {
            try migrator.migrate(dbPool)
            osLog("Database Ready @ \(currentDBPath.path)")

            state.value = .ready
        } catch {
            state.value = .migrationError(error)
            osLog("Configure Errored: \(error)")
            throw error
        }
    }

    // this publisher waits for the database to be ready
    var databaseReadyPublisher: AnyPublisher<Void, Error> {
        state
            .setFailureType(to: Error.self)
            .flatMap { currentState -> AnyPublisher<Void, Error> in
                if currentState == .ready {
                    return Just.errorable(())
                } else {
                    return self.state
                        .filter { $0 == .ready }
                        .map { _ in () }
                        .setFailureType(to: Error.self)
                        .timeout(2.0, scheduler: RunLoop.main, customError: { DatabaseError("Database not Ready") })
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func readPublisher<Output>(
        value: @escaping (Database) throws -> Output) -> DatabasePublishers.Read<Output>
    {
        dbPool.readPublisher(value: value)
    }

    func writePublisher<Output>(
        updates: @escaping (Database) throws -> Output
    ) -> DatabasePublishers.Write<Output> {
        dbPool.writePublisher(
            receiveOn: DispatchQueue.global(),
            updates: updates
        )
    }

    func asyncWrite<T>(updates: @escaping (Database) async throws -> T) async throws {
        try await dbPool.write { _ in
            // return try await updates(db)
        }

//        try await dbPool
//            .write{ db in
//                try await updates(db)
//            }
    }

    func read<Output>(
        updates: @escaping (Database) throws -> Output
    ) throws -> Output {
        guard state.value == .ready else { throw DatabaseError("Database not started") }
        return try dbPool.read(updates)
    }

    func write(
        updates: @escaping (Database) throws -> Void
    ) throws {
        guard state.value == .ready else { throw DatabaseError("Database not started") }
        try dbPool.write(updates)
    }

    func fetchOne<T: GRDB.Record>(key: [String: DatabaseValueConvertible]) -> AnyPublisher<T?, Error> {
        readPublisher { db in try T.filter(key: key).fetchOne(db) }.eraseToAnyPublisher()
    }

    func fetchAll<T: GRDB.Record>(_ request: QueryInterfaceRequest<T>) -> AnyPublisher<[T], Error> {
        databaseReadyPublisher
            .flatMap {
                self.readPublisher { db in try request.fetchAll(db) }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// observe table changes on a single object.
    func observeSingle<T: GRDB.Record>(_ request: QueryInterfaceRequest<T>) -> AnyPublisher<T?, Error> {
        let observation = ValueObservation.tracking { db in try request.fetchOne(db) as T? }
        return databaseReadyPublisher
            .flatMap {
                observation.publisher(in: self.dbPool).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// observe all changes based on a query.
    func observeAll<T: GRDB.Record>(_ request: QueryInterfaceRequest<T>) -> AnyPublisher<[T], Error> {
        let observation = ValueObservation.tracking { db in
            try request.fetchAll(db)
        }
        return observation.publisher(in: dbPool).eraseToAnyPublisher()
    }

    /// observe Count changes based on a query.
    func observeCount<T: GRDB.Record>(_ request: QueryInterfaceRequest<T>) -> AnyPublisher<Int, Error> {
        let observation = ValueObservation.tracking { db in try request.fetchCount(db) }
        return observation.publisher(in: dbPool).eraseToAnyPublisher()
    }

    func clearAll() throws {}
}
