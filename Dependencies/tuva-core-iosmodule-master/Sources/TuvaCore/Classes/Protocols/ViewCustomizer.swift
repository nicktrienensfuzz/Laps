//
// ViewCustomizer.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation

/// provide standardized functions for building and constraining subviews
public protocol ViewCustomizer {
    func addViews()
    func constrainViews()
    func styleViews()
}
