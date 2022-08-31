//
//  Endpoint.swift
//  FuzzCombine
//
// Created by Nick Trienens on 3/12/20.
// Copyright © 2020 Fuzzproductions. All rights reserved.
//

import Combine
import Foundation

// Mark - Endpoint Helpers
public enum Parameters {
  case parameter([String: String], Encoding)
  case encodable(AnyEncodable, Encoding)
}

open class Endpoint {
    public let method: HTTPMethod
    public let urlPath: String
    open var headers: [String: String]?
    open var parameters: [Parameters]

    // Build a Endpoint
    public init(method: HTTPMethod,
         path: String,
         parameters: [Parameters] = [Parameters](),
         headers: [String: String]? = nil
    ) {

        self.method = method
        self.parameters = parameters
        self.headers = headers
        urlPath = path
    }
    
    open func constructURL( baseUrl: String, path: String) -> URL? {
        URL(string: baseUrl + path)
    }

    /// Build a reasonable URLRequest from a Endpoint
    /// - Parameter baseUrl String for the request
    /// - Parameter encoder to encode Codable pararmters to json
    /// - Returns: URLRequest with parameter and headers added
    open func request(baseUrl: String, encoder: JSONEncoder = JSONEncoder()) -> AnyPublisher<URLRequest, Error> {
        var path = urlPath

        var body: Data?
        do {
            try parameters.forEach { parameter in
                switch parameter {
                    case let .parameter(params, encoding):
                        switch encoding {
                        case .body:
                            body = try encoder.encode(params)
                            case .urlEncodedBody:
                                body = params.httpParameters(includeQuestionMark: false).data(using: .utf8)
                            case .queryString:
                                path += params.httpParameters()

                        }
                    case let .encodable(wrapper, encoding):
                        switch encoding {
                        case .body:
                            body = try encoder.encode(wrapper)
                        case .queryString, .urlEncodedBody:
                            throw HTTPError("Couldn't encode anyEncodable to  queryString")
                        }
                }
            }
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        guard let url = constructURL( baseUrl: baseUrl, path: path) else {
            return Fail(error: HTTPError("request url could not be constructed"))
                .eraseToAnyPublisher()
        }
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method.rawValue

        headers?.forEach { (key: String, value: String) in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = body {
            request.httpBody = body
        }

        let completeRequest = request as URLRequest
        return Just(completeRequest)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// typeEaraser Wrapper around Encodable
public struct AnyEncodable: Encodable {
  public let encodable: Encodable

  public init(_ encodable: Encodable) {
      self.encodable = encodable
  }

  public func encode(to encoder: Encoder) throws {
      try encodable.encode(to: encoder)
  }
}

public enum Encoding: String {
    case body
    case queryString
    case urlEncodedBody
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case head = "HEAD"
    case option = "OPTION"
    case delete = "DELETE"
}
