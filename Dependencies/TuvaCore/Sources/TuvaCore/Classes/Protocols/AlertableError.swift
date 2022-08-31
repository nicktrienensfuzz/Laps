//
// AlertableError.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation

public protocol AlertableError: Error {
    var message: String { get }
}
