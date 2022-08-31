//
//  TestArrayExtensions.swift
//  tuva-core-example
//
//  Created by Stavros Ladeas on 5/20/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import tuva_core_example
import TuvaCore

class TestArrayExstensions: QuickSpec {
    override func spec() {
        describe("ArrayExtensions") {
            let originalArray = ["zero", "one", "two", "three", "four"]
            var element: String?
            var slice = [String]()

            context("Take") {
                // test `takeFirst`
                it("First -100") {
                    slice = originalArray.takeFirst(-100)
                    expect(slice.count) == 0
                }

                it("First 0") {
                    slice = originalArray.takeFirst(0)
                    expect(slice.count) == 0
                }

                it("First 1") {
                    slice = originalArray.takeFirst(1)
                    expect(slice.count) == 1
                }

                it("First 3") {
                    slice = originalArray.takeFirst(3)
                    expect(slice.count) == 3
                }

                it("First 5") {
                    slice = originalArray.takeFirst(5)
                    expect(slice.count) == 5
                }

                it("First 100") {
                    slice = originalArray.takeFirst(6)
                    expect(slice.count) == originalArray.count
                }

                // test `takeLast`
                it("Last -100") {
                    slice = originalArray.takeLast(-100)
                    expect(slice.count) == 0
                }

                it("Last 0") {
                    slice = originalArray.takeLast(0)
                    expect(slice.count) == 0
                }

                it("Last 1") {
                    slice = originalArray.takeLast(1)
                    expect(slice.count) == 1
                }

                it("Last 3") {
                    slice = originalArray.takeLast(3)
                    expect(slice.count) == 3
                }

                it("Last 5") {
                    slice = originalArray.takeLast(5)
                    expect(slice.count) == 5
                }

                it("Last 100") {
                    slice = originalArray.takeLast(100)
                    expect(slice.count) == originalArray.count
                }
            }

            context("Element") {
                it("At -100") {
                    slice = originalArray.takeLast(-100)
                    expect(element).to(beNil())
                }

                it("At 0") {
                    element = originalArray.element(at: 0)
                    expect(element) == "zero"
                }

                it("At 1") {
                    element = originalArray.element(at: 1)
                    expect(element) == "one"
                }

                it("At 3") {
                    element = originalArray.element(at: 3)
                    expect(element) == "three"
                }

                it("At 5") {
                    element = originalArray.element(at: 5)
                    expect(element).to(beNil())
                }

                it("At 100") {
                    element = originalArray.element(at: 100)
                    expect(element).to(beNil())
                }
            }

            context("Elements") {
                it("Equaling \"one") {
                    slice = originalArray.elements(equaling: "one")
                    expect(slice.count) == originalArray.count + 1
                }

                it("Equaling \"unavailableElement") {
                    slice = originalArray.elements(equaling: "unavailableElement")
                    expect(slice.count) == originalArray.count
                }
            }

            context("Element") {
                it("Equaling 'one'") {
                    element = originalArray.element(equaling: "one")
                    expect(element) == "one"
                }

                it("Equaling 'one', not 'two'") {
                    element = originalArray.element(equaling: "one")
                    expect(element) != "two"
                }

                it("Equaling 'unavailableElement'") {
                    element = originalArray.element(equaling: "unavailableElement")
                    expect(element).to(beNil())
                }

                it("Removing 'one'") {
                    slice = originalArray.removing(item: "one")
                    expect(slice.count) == originalArray.count - 1
                }

                it("Removing 'unavailableElement'") {
                    slice = originalArray.removing(item: "unavailableElement")
                    expect(slice.count) == originalArray.count
                }

                it("Remove 'one'") {
                    // creating `array`, as to not disrupt other tests from mutated array
                    var array = ["zero", "one", "two", "three", "four"]
                    array.remove(item: "one")
                    expect(array.count) == 4
                }

                it("Remove 'unavailableElement'") {
                    // creating `array`, as to not disrupt other tests from mutated array
                    var array = ["zero", "one", "two", "three", "four"]
                    array.remove(item: "unavailableElement")
                    expect(array.count) == 5
                }
            }

            context("Subtract") {
                it("All identical") {
                    let firstArray = ["zero", "one", "two", "three", "four"]
                    let secondArray = ["zero", "one", "two", "three", "four"]
                    let newArray = firstArray - secondArray
                    expect(newArray.count) == 0
                }

                it("All different") {
                    let firstArray = ["zero", "one", "two", "three", "four"]
                    let secondArray = ["five", "six", "seven", "eight", "nine"]
                    let newArray = firstArray - secondArray
                    expect(newArray) == firstArray
                }

                it("Some different") {
                    let firstArray = ["zero", "one", "two", "three", "four"]
                    let secondArray = ["zero", "five", "six", "three", "four"]
                    let newArray = firstArray - secondArray
                    expect(newArray) == ["one", "two"]
                }
            }

            context("Replacing") { // TODO: - create more meaningful tests
                // new item will replace existing item, therefore returning same array
                it("Item 'one'") {
                    slice = originalArray.replacing(item: "one")
                    expect(slice) == originalArray
                }

                it("Item 'unavailableElement'") {
                    // new item will not replace existing item, therefore returning same array
                    slice = originalArray.replacing(item: "unavailableElement")
                    expect(slice) == originalArray
                }

                it("Item 'one' insertWhenNotFound = true") {
                    do { slice = try originalArray.replacing(item: "one", insertWhenNotFound: true)
                    } catch { print(error) }
                    expect(slice) == originalArray
                }

                it("Item 'one' insertWhenNotFound = false") {
                    do { slice = try originalArray.replacing(item: "one", insertWhenNotFound: false)
                    } catch { print(error) }
                    expect(slice) == originalArray
                }

                it("Item 'newItem' insertWhenNotFound = true") {
                    do { slice = try originalArray.replacing(item: "newItem", insertWhenNotFound: true)
                    } catch { print(error) }
                    expect(slice.count) == originalArray.count + 1
                }

                it("Item 'newItem' insertWhenNotFound = false") {
                    var newSlice = [String]()
                    let thisArray = ["zero", "one", "two", "three", "four"]
                    do { slice = try thisArray.replacing(item: "newItem", insertWhenNotFound: false)
                    } catch { print(error) }
                    expect(slice.count) == thisArray.count
                    // TODO: - Failing, look at function
                }
            }

            context("Replace") { // TODO: - create more meaningful tests
                it("Item 'availableItem'") {
                    // creating `newArray`, as to not disrupt other tests from mutated array
                    var newArray = ["availableItem", "one", "two", "three", "four"]
                    newArray.replace("availableItem")
                    expect(newArray) == newArray
                }

                it("Item 'newItem'") {
                    // creating `newArray`, as to not disrupt other tests from mutated array
                    var newArray = ["availableItem", "one", "two", "three", "four"]
                    newArray.replace("newItem")
                    expect(newArray) == newArray
                }
            }

            context("As Array") {
                it("For Midpoint Count") {
                    let array = ["zero", "one", "two", "three", "four"]
                    let midpoint = array.count / 2
                    let firstHalfSlice = array[..<midpoint]
                    expect(firstHalfSlice.asArray.count) == array.count / 2
                }

                it("For First Half Slice") {
                    let array = ["zero", "one", "two", "three", "four"]
                    let midpoint = array.count / 2
                    let firstHalfSlice = array[..<midpoint]
                    expect(firstHalfSlice.asArray) == ["zero", "one"]
                }

                it("For First Half Slice (Unequal)") {
                    let array = ["zero", "one", "two", "three", "four"]
                    let midpoint = array.count / 2
                    let firstHalfSlice = array[..<midpoint]
                    expect(firstHalfSlice.asArray) != ["zero", "two"]
                }
            }

            context("Deduplicated") {
                it("0 duplicates") {
                    let array = ["zero", "one", "two", "three", "four"]
                    let newArray = array.deduplicated()
                    expect(newArray.count) == array.count
                }

                it("2 duplicates") {
                    let array = ["duplicate", "duplicate", "two", "three", "four"]
                    let newArray = array.deduplicated()
                    expect(newArray.count) == array.count - 1
                }

                it("3 duplicates") {
                    let array = ["duplicate", "duplicate", "duplicate", "three", "four"]
                    let newArray = array.deduplicated()
                    expect(newArray.count) == array.count - 2
                }

                it("All duplicates") {
                    let array = ["duplicate", "duplicate", "duplicate", "duplicate", "duplicate"]
                    let newArray = array.deduplicated()
                    expect(newArray.count) == 1
                }
            }

            context("Deduplicate") {
                it("0 duplicates") {
                    var array = ["zero", "one", "two", "three", "four"]
                    array.deduplicate()
                    expect(array.count) == 5
                }

                it("2 duplicate") {
                    var array = ["duplicate", "duplicate", "two", "three", "four"]
                    array.deduplicate()
                    expect(array.count) == 4
                }

                it("3 duplicate") {
                    var array = ["duplicate", "duplicate", "duplicate", "three", "four"]
                    array.deduplicate()
                    expect(array.count) == 3
                }

                it("All duplicate") {
                    var array = ["duplicate", "duplicate", "duplicate", "duplicate", "duplicate"]
                    array.deduplicate()
                    expect(array.count) == 1
                }
            }
        }
    }
}
