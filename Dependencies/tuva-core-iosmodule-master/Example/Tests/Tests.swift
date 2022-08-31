//
// Tests.swift
// TuvaCore
//
// Created by Nicholas Trienens on 5/19/20.
// Copyright © 2020 Fuzzproductions, LLC. All rights reserved.

import Nimble
import Quick
@testable import tuva_core_example
import TuvaCore

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("extensions") {
            context("Codable") {
                let user = User(name: "Nick")
                it("Encode to Data") {
                    expect(try! user.toData().count).to(beGreaterThan(10))
                }

                let userString = try! user.toString()

                it("Encode to Json") {
                    print(userString)
                    expect(userString.count).to(beGreaterThan(10))
                }
                it("Decode Json String to object") {
                    let decodedUser: User = try! userString.decode()
                    expect(decodedUser.id) == user.id
                }
            }
            context("these will pass") {
                it("can do maths") {
                    expect(23) == 23
                }

                it("can read") {
                    expect("🐮") == "🐮"
                }

                it("will eventually pass") {
                    var time = "passing"

                    DispatchQueue.main.async {
                        time = "done"
                    }

                    waitUntil { done in
                        Thread.sleep(forTimeInterval: 0.5)
                        expect(time) == "done"

                        done()
                    }
                }
            }
        }
    }
}
