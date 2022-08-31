//
//  Client.swift
//  FuzzCombine
//
// Created by Nick Trienens on 3/12/20.
// Copyright © 2020 Fuzzproductions. All rights reserved.
//

import Combine
import Foundation
import os

/// Subclass Client to in you app to make a meaningful network layer
open class Client {
    public var session: URLSession
    
    public var allowedStatusCodes = 200 ... 299
    
    public var baseUrl: String
    
    public var printer: ((String)-> Void)? = { print($0) }
    public var debugging: [Debugging] = [.successLimited(500), .errors]
    public var requestIndex: Int = 0
    
    public init(baseURLString: String = "", session: URLSession = URLSession.shared) {
        baseUrl = baseURLString
        self.session = session
    }
    
    /// Make a network request via URLSession.dataTaskPublisher
    /// - Parameter endpoint: Endpoint
    /// - Parameter encoder: allows overriding teh default Json Coding 
    /// - Returns: AnyPublisher<Data, Error>
    open func request(_ endpoint: Endpoint, encoder: JSONEncoder = JSONEncoder()) -> AnyPublisher<Data, Error> {
        return
            endpoint.request(baseUrl: baseUrl, encoder: encoder)
            .flatMap { [weak self] request -> AnyPublisher<Data, Error> in
                guard let self = self else {
                    return Fail(error: HTTPError.weakSelfError())
                        .eraseToAnyPublisher()
                }
                let currentRequest = self.requestIndex
                self.requestIndex += 1
                
                self.debugIfContains(.info,
                                     messages: ["Making request<\(currentRequest)>: \(request.url?.absoluteString ?? "no Url")"])
                self.debugIfContains(.curlBefore,
                                     messages: ["Request Before<\(currentRequest)>: \(request.cURLRepresentation())"])
                
                return self.session.dataTaskPublisher(for: request)
                    .tryMap { [weak self] output -> Data in
                        guard let self = self else {
                            throw HTTPError.weakSelfError()
                        }
                        let response = try self.validateResponse(output, fromRequest: request, currentRequest: currentRequest)
                        try self.validateStatusCode(request: request, response: response, output: output, currentRequest: currentRequest)
                        
                        self.debugValidResponse(request: request, response: response, output: output, currentRequest: currentRequest)
                        return output.data
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    open func debugIfContains(_ value: Debugging,
                              messages: [String],
                              completion: ((_: Bool) -> Void)? = nil) {
        guard debugging.contains(value) else {
            completion?(false)
            return
        }
        messages.forEach { printer?($0) }
        completion?(true)
    }
    
    open func validateResponse(_ output: URLSession.DataTaskPublisher.Output,
                             fromRequest request: URLRequest,
                               currentRequest: Int) throws -> HTTPURLResponse {
        guard let response = output.response as? HTTPURLResponse else {
            throw handleInvalidResponse(withRequest: request, currentRequest: currentRequest)
        }
        return response
    }
    
    open func handleInvalidResponse(withRequest request: URLRequest, currentRequest: Int) -> HTTPError {
      
        debugIfContains(.errors,
                        messages: ["Empty Response Received<\(currentRequest)>"]) { [weak self] containsValue in
            if containsValue {
                self?.debugIfContains(.curl,
                                      messages: ["Request Error<\(currentRequest)>: \(request.cURLRepresentation())"])
            }
        }
        
        debugIfContains(.completion,
                        messages: ["Empty Response Received<\(currentRequest)>"])
        
        return HTTPError.noResponse()
    }
    
    @discardableResult
    open func validateStatusCode(request: URLRequest,
                                 response: HTTPURLResponse,
                                 output: URLSession.DataTaskPublisher.Output,
                                 currentRequest: Int) throws -> Bool {
        guard allowedStatusCodes.contains(response.statusCode) else {
            throw handleUnallowedStatusCode(request: request,
                                            response: response,
                                            output: output,
                                            currentRequest: currentRequest)
        }
        return true
    }
    
    open func handleUnallowedStatusCode(request: URLRequest,
                                        response: HTTPURLResponse,
                                        output: URLSession.DataTaskPublisher.Output,
                                        currentRequest: Int) -> HTTPError {
        
        let errorMessages = ["Bad Status Code<\(currentRequest)>: \(response.statusCode)",
                             "Error<\(currentRequest)>: \(String(data: output.data, encoding: .utf8) ?? "No Body")"]
        
        debugIfContains(.errors,
                        messages: errorMessages) { [weak self] containsValue in
            self?.debugIfContains(.curl,
                                  messages: ["Request Bad Status<\(currentRequest)>: \(request.cURLRepresentation())"])
        }
        
        debugIfContains(.completion,
                        messages: ["Bad Status Code<\(currentRequest)>: \(response.statusCode)"])
        
        return HTTPError.invalidStatusCode(response.statusCode, response: String(data: output.data, encoding: .utf8), urlString: request.url?.absoluteString)
    }
    
    open func debugValidResponse(request: URLRequest,
                                 response: HTTPURLResponse,
                                 output: URLSession.DataTaskPublisher.Output,
                                currentRequest: Int) {
        
        
        if debugging.containsSuccess {
            debugIfContains(.curl,
                            messages: ["Request Succeded<\(currentRequest)>: \(request.cURLRepresentation())"])
            
            if let limit = self.debugging.limit {
                self.printer?("Success<\(currentRequest)>: \(String(data: output.data, encoding: .utf8)?.prefix(limit).asString ?? "No Body")")
            } else {
                self.printer?("Success<\(currentRequest)>: \(String(data: output.data, encoding: .utf8) ?? "No Body")")
            }
        }
        
        debugIfContains(.completion,
                        messages: ["Success Status Code<\(currentRequest)>: \(response.statusCode)"])
    }
}

fileprivate extension Substring {
    var asString: String {
        String(self)
    }
}
