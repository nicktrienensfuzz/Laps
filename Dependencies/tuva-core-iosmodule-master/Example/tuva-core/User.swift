//
// User.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation

struct User: Codable {
    let id: String
    let name: String
    init(name: String) {
        self.name = name
        id = UUID().uuidString
    }
}
