//
// Created by Andrew Grosner on 3/22/21.
// Copyright (c) 2021 Fuzzproductions. All rights reserved.
//

import Foundation
import GRDB

protocol TableCreator {
    static func createTable(db: Database) throws -> Void
    static var databaseTableName: String { get }
}
