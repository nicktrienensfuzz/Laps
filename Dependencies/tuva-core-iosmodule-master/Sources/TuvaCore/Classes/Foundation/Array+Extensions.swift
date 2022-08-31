//
// Array+Extensions.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Foundation

public extension Array {
    /// Retrieve a segment of elements from the start of array per `number` specified.
    /// - Parameter number: Positve `Int` value representing the first segment of these elements.
    /// - Returns: The first slice of original array composed of the `number` specified.
    func takeFirst(_ number: Int) -> [Element] {
        guard number > 0 else { return [] }
        guard number < count else { return self }
        return self[0 ..< number].asArray
    }

    /// Retrieve a segment of elements from the end of array per `number` specified.
    /// - Parameter number: Positive `Int` value representing the last segment of these elements.
    /// - Returns: The last slice of original array composed of the `number` specified.
    func takeLast(_ number: Int) -> [Element] {
        guard number > 0 else { return [] }
        let start = Swift.max(0, count - number)
        return self[start ..< count].asArray
    }

    /// Retrieve one element from array at the `index` specified.
    /// - Parameter index: Value representing the location of element to be accessed from array.
    /// - Returns: An optional element accessed from the `index` specified.
    func element(at index: Int) -> Element? {
        if count > 0, count > index {
            return self[index]
        } else {
            return nil
        }
    }
    
    
    /// Retrieve a segment of elements skipping the first `number` specified.
    /// - Parameter number: Positive `Int` value representing the last segment of these elements.
    /// - Returns: The last slice of original array composed of the `number` specified.
    func removingFirst(_ number: UInt) -> [Element] {
        var newArray = self
        guard count > number else {
            return []
        }
        guard number > 0 else {
            return newArray
        }
        newArray.removeFirst(Int(number))
        return newArray
    }

}

public extension Array where Iterator.Element: Equatable {
    /// Subtract one array's elements from another array's
    /// - Parameters:
    ///   - lhs: array of Equatable items
    ///   - rhs: array of Equatable items
    static func - (lhs: Array, rhs: Array) -> Array {
        lhs.filter { !rhs.contains($0) }
    }

    /// Create an array from existing array plus new item if it is unique.
    /// - Parameter item: Equatable item to be added if it is unique.
    /// - Returns: An array with new item if it is unique.
    func elements(equaling item: Iterator.Element) -> [Iterator.Element] {
        var newArray = self
        for obj in self where obj == item {
            newArray.append(obj)
        }
        return newArray
    }

    /// Return an element, if one passed in exists in the array.
    /// - Parameter item: Equatable item
    /// - Returns: An element if one existed
    func element(equaling item: Iterator.Element) -> Iterator.Element? {
        for obj in self where obj == item {
            return obj
        }
        return nil
    }

    /// Create new array wtih a specified item in array to be removed.
    /// - Parameter item: Equatable item
    /// - Returns: New array without specified item if it existed in original array.
    func removing(item: Iterator.Element) -> [Iterator.Element] {
        var newArray = self
        if let ind = newArray.firstIndex(of: item) {
            newArray.remove(at: ind)
        }
        return newArray
    }

    /// Remove existing item from array.
    /// - Parameter item: Item to be removed from array.
    mutating func remove(item: Iterator.Element) {
        if let ind = firstIndex(of: item) {
            remove(at: ind)
        }
    }

    /// Create a new array replacing any items in the array Equatable to the passed in item.
    /// - Parameter item: Equatable item
    /// - Returns: New array
    func replacing(item: Iterator.Element) -> [Iterator.Element] {
        let newArr: [Iterator.Element] = map { oldItem in
            if oldItem == item {
                return item
            }
            return oldItem
        }
        return newArr
    }

    /// Create a new array replacing any items in the array Equatable to the passed in item with the option to add it.
    /// - Parameters:
    ///   - item: Equaltable item
    ///   - insertWhenNotFound: Flag to determine if new element should be added if an Equatable one does not exist.
    /// - Throws: Error when no item is matched
    /// - Returns: New array with replaced items if any Equatable item(s) exist and flag is set to true.
    func replacing(item: Iterator.Element, insertWhenNotFound: Bool) throws -> [Iterator.Element] {
        var noItemsMatched = true
        var newArr: [Iterator.Element] = map { oldItem in
            if oldItem == item {
                noItemsMatched = false
                return item
            }
            return oldItem
        }
        if insertWhenNotFound, noItemsMatched {
            newArr.append(item)
            return newArr
        }
        if noItemsMatched {
            let error = TuvaError("failed to find a matching element")
            throw error
        }
        return newArr
    }

    /// Replace an element of array with a matching element.
    /// - Parameter item: Item to replace an existing Equatable item
    mutating func replace(_ item: Iterator.Element) {
        let newArr: [Iterator.Element] = map { oldItem in
            if oldItem == item {
                return item
            }
            return oldItem
        }
        self = newArr
    }
}

public extension ArraySlice {
    /// Create an array from an array slice.
    var asArray: [Element] { Array(self) }
}

public extension Array where Element: Hashable {
    /// Create a new `Array` without duplicate elements.
    /// - Note: The initial order of the elements is not maintained in the returned value.
    ///
    /// - Returns: A new `Array` without duplicate elements.
    ///
    func deduplicated() -> Array {
        Array(Set<Element>(self))
    }

    /// Strip duplicate elements from the array.
    /// - Note:  The initial order of the elements is not maintained after the strip.
    mutating func deduplicate() {
        self = deduplicated()
    }
}

public extension Array {
    func deduplicated(_ includeElement: (Element, Element) -> Bool) -> Array {
        var results = [Element]()

        forEach { element in
            let existingElements = results.filter {
                includeElement(element, $0)
            }
            if existingElements.count == 0 {
                results.append(element)
            }
        }

        return results
    }
}
