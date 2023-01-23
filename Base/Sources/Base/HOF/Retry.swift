//
//  Retry.swift
//  
//
//  Created by Nicholas Trienens on 1/4/23.
//

import Foundation

func retry<T>(maxRetries: Int = 3, delayBetweenRetries: Double = 0.25, block: () throws -> T) throws -> T {
    var attempts = 0
    while true {
        do {
            return try block()
        } catch {
            attempts += 1
            if attempts > maxRetries {
                throw error
            }
            Thread.sleep(forTimeInterval: delayBetweenRetries)
        }
    }
}

func retry<T>(maxRetries: Int, delayBetweenRetries: Double, block: (Int) async throws -> T) async throws -> T {
    var attempts = 0
    while true {
        do {
            return try await block(attempts)
        } catch {
            attempts += 1
            if attempts > maxRetries {
                throw error
            }
            
            try await Task.sleep(nanoseconds: NSEC_PER_MSEC * UInt64(delayBetweenRetries * 1000))
        }
    }
}
