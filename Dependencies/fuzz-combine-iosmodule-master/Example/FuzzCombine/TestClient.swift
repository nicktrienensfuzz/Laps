//
//  TestClient.swift
//  FuzzCombine_Example
//
//  Created by Nick Trienens on 4/28/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Combine
import Foundation
import FuzzCombine

class TestClient: Client {
    // Decoding helpers
    struct User: Decodable {
        let id: String
        let createdAt: String
        let name: String
    }

    func fetchMe() -> AnyPublisher<User, Error> {
        debugging = [.curl, .completion, .info]
        let target = Endpoint(
            method: .get,
            path: "/me",
            parameters: [.parameter(["test": "345"], .queryString)]
        )

        return request(target)
            .decode(type: User.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
