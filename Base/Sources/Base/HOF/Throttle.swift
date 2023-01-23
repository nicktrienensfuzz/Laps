//
//  throttle.swift
//  
//
//  Created by Nicholas Trienens on 1/4/23.
//

import Foundation

public func throttle(interval: TimeInterval, block: @escaping () -> Void) -> () -> Void {
    var lastExecutionTime: TimeInterval = Date.distantPast.timeIntervalSince1970
    return {
        let now = Date().timeIntervalSince1970
        let elapsedTime = now - lastExecutionTime
        if elapsedTime > interval {
            lastExecutionTime = now
            block()
        }
    }
}

public func throttleOne<T>(interval: TimeInterval, block: @escaping (T) -> Void) -> (T) -> Void {
    var lastExecutionTime: TimeInterval = Date.distantPast.timeIntervalSince1970
    return {
        let now = Date().timeIntervalSince1970
        let elapsedTime = now - lastExecutionTime
        if elapsedTime > interval {
            lastExecutionTime = now
            block($0)
        }
    }
}

/*
 This function creates a new function that records the last time the block of code was executed. When the new function is called, it checks the elapsed time since the last execution. If the elapsed time is greater than the time interval, it executes the block of code and updates the last execution time. If the elapsed time is less than the time interval, it does nothing.

 You can use this function by passing it a block of code and a time interval and then calling the returned function whenever you want to throttle the execution of the code block. For example:

 Copy code
 let throttledFunction = throttle(interval: 1.0) {
     print("Throttled function called!")
 }

 throttledFunction() // prints "Throttled function called!"
 throttledFunction() // does nothing
 throttledFunction() // does nothing
 throttledFunction() // does nothing

 // After 1 second:
 throttledFunction() // prints "Throttled function called!"
 throttledFunction() // does nothing
 */
