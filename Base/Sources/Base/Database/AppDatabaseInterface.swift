//
//  AppDatabaseInterface.swift
//
//
//  Created by Nicholas Trienens on 4/19/21.
//
#if canImport(GRDB)

    import Combine
    import Foundation
    import GRDB

    public protocol AppDatabaseInterface {
        func configure() throws
        var databaseReadyPublisher: AnyPublisher<Void, Error> { get }

        func readPublisher<Output>(
            value: @escaping (Database) throws -> Output) -> DatabasePublishers.Read<Output>
        func writePublisher<Output>(
            updates: @escaping (Database) throws -> Output) -> DatabasePublishers.Write<Output>

        func asyncWrite(
            updates: @escaping (Database) async throws -> Void) async throws

        func fetchOne<T: GRDB.Record>(key: [String: DatabaseValueConvertible]) -> AnyPublisher<T?, Error>

        func fetchAll<T: GRDB.Record>(_ request: QueryInterfaceRequest<T>) -> AnyPublisher<[T], Error>

        // long lived Observation
        func observeSingle<T: GRDB.Record>(_ request: QueryInterfaceRequest<T>) -> AnyPublisher<T?, Error>
        func observeAll<T: GRDB.Record>(_ request: QueryInterfaceRequest<T>) -> AnyPublisher<[T], Error>
        func observeCount<T: GRDB.Record>(_ request: QueryInterfaceRequest<T>) -> AnyPublisher<Int, Error>

        var currentDBPath: URL { get }
        func clearAll() throws

        var dbPool: DatabaseWriter { get }
        
        func exportDatabaseContent(from dbPool: DatabaseWriter) throws -> String
    }

    public protocol AppDatabaseSynchronousInterface {
        func read<Output>(updates: @escaping (Database) throws -> Output) throws -> Output
        func write(updates: @escaping (Database) throws -> Void) throws
        var dbPool: DatabaseWriter { get }
    }

    enum AppDatabaseState: Equatable {
        case notStarted
        case opened
        case fileError(Error)
        case migrationError(Error)
        case ready

        static func == (lhs: AppDatabaseState, rhs: AppDatabaseState) -> Bool {
            switch (lhs, rhs) {
            case (.ready, .ready): return true
            case (.fileError, .fileError): return true
            case (.migrationError, .migrationError): return true
            case (.opened, .opened): return true
            case (.notStarted, .notStarted): return true
            default:
                return false
            }
        }
    }
#endif
