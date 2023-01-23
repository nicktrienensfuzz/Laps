//
//  LapsTests.swift
//  LapsTests
//
//  Created by Nicholas Trienens on 6/20/22.
//

import XCTest
@testable import Laps
import FuzzCombine
import Combine

class LapsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() async throws {
        func t() async throws {
            let test: Laps.Reference<String?> = Laps.Reference<String?>(value: "test")
            
            Task{
                try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
                test.value = nil
            }
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
            let v = try await test.currentValueWithUpdates.async()
            
            debugPrint(v)
            XCTAssertNil(v)
        }

        try await t()
        try await t()

    }
    
    func testMapExample() async throws {
        
        let test: Laps.Reference<String?> = Laps.Reference<String?>(value: "test")
        
        Task{
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
            test.value = nil
        }
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
        let v = try await test.didUpdate.async()
            
        print(v)
        XCTAssertNil(v)
    }
    
    
    func testCurrentExample() async throws {
        func t() async throws {
            let test: FuzzCombine.Reference<String?> = FuzzCombine.Reference<String?>(value: "test")
            
            Task{
                try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
                test.value = nil
            }
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
            let v = try await test.currentValueWithUpdates.async()
            
            debugPrint(v)
            XCTAssertNil(v)
        }

        try await t()
        try await t()

    }
    func testFuzzCombineExample() async throws {
        
        let test: FuzzCombine.Reference<String?> = FuzzCombine.Reference<String?>(value: "test")
        
        Task{
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
            test.value = nil
        }
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
        let v = try await test.currentValueWithUpdates.async()
        
        print(v)
        XCTAssertNil(v)
    }


}


extension AnyPublisher {
    enum ExpectedValueError: Error {
        case publisherFinishedBeforeProducingAValue
    }
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var valueProduced = false
            
            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        if !valueProduced {
                            continuation.resume(throwing: ExpectedValueError.publisherFinishedBeforeProducingAValue)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    valueProduced = true
                    continuation.resume(with: .success(value))
                }
        }
    }
}
