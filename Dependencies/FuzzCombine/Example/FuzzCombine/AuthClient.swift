//
//  AuthClient.swift
//  FuzzCombine_Example
//
//  Created by Nick Trienens on 8/13/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Combine
import Foundation
import FuzzCombine

class AuthClient: FuzzCombine.Client {
    static var token: Token?

    init() {
        super.init(baseURLString: "https://dev-api.fuzztival.fuzzplay.io/auth/realms/dev/protocol/openid-connect/token")
        debugging = [.curl, .errors, .info, .success]
        // tryLog { self.token = try Keychain.get(key: .token)?.decode() }
    }

    static func signRequest(_ request: URLRequest) -> Future<URLRequest, Error> {
        let signedRequestResponse = Future<URLRequest, Error> { promise in
            guard let request = request as? NSMutableURLRequest else { return promise(.failure(HTTPError("not mutable"))) }

            if let token = AuthClient.token {
                request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
                promise(.success(request as URLRequest))
            } else {
                promise(.failure(HTTPError("no Token found")))
            }
        }

        return signedRequestResponse
    }

    func signIn() -> AnyPublisher<Token, Error> {
        let target = Endpoint(
            method: .post,
            path: "",
            parameters: [.parameter([
                "username": "zar@fuzz.pro",
                "password": "password",
                "grant_type": "password",
                "client_id": "native"
            ], .body)]
        )
        target.headers?["Content-Type"] = "application/x-www-form-urlencoded"
        return request(target, encoder: JSONEncoder())
            .decode(type: Token.self, decoder: JSONDecoder())
            .map { token in
                AuthClient.token = token
                return token
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Token
struct Token: Codable {
    let accessToken: String
    let expiresIn: Int?
    let refreshExpiresIn: Int?
    let refreshToken: String
    let tokenType: String?
    let notBeforePolicy: Int?
    let sessionState: String?
    let scope: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshExpiresIn = "refresh_expires_in"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case notBeforePolicy = "not-before-policy"
        case sessionState = "session_state"
        case scope
    }
}
