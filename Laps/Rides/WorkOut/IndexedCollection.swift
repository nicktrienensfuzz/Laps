//
//  File.swift
//
//
//  Created by Nicholas Trienens on 3/30/22.
//

import Foundation

// This is taken from the Release Notes, with a typo correction, marked below
public struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
    public typealias Index = Base.Index
    public typealias Element = (index: Index, element: Base.Element)

    public let base: Base

    public var startIndex: Index { base.startIndex }

    // corrected typo: base.endIndex, instead of base.startIndex
    public var endIndex: Index { base.endIndex }

    public func index(after i: Index) -> Index {
        base.index(after: i)
    }

    public func index(before i: Index) -> Index {
        base.index(before: i)
    }

    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        base.index(i, offsetBy: distance)
    }

    public subscript(position: Index) -> Element {
        (index: position, element: base[position])
    }
}

public extension RandomAccessCollection {
    func indexed() -> IndexedCollection<Self> {
        IndexedCollection(base: self)
    }
}
