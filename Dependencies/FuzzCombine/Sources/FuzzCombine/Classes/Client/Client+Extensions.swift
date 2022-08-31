//
//  cleint+extensions.swift
//  FuzzCombine
//
//  Created by Nick Trienens on 6/19/20.
//

import Foundation


extension String {
  
  /**
   Returns a new string made from the receiver by replacing characters which are
   reserved in a URI query with percent encoded characters.
   
   The following characters are not considered reserved in a URI query
   by RFC 3986:
   
   - Alpha "a...z" "A...Z"
   - Numberic "0...9"
   - Unreserved "-._~"
   
   In addition the reserved characters "/" and "?" have no reserved purpose in the
   query component of a URI so do not need to be percent escaped.
   
   - Returns: The encoded string, or nil if the transformation is not possible.
 */
  
  public func stringByAddingPercentEncodingForRFC3986() -> String {
    let unreserved = "-._~/?"
    let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
    allowedCharacterSet.addCharacters(in: unreserved)
    return addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? self
  }
  
  /**
   Returns a new string made from the receiver by replacing characters which are
   reserved in HTML forms (media type application/x-www-form-urlencoded) with
   percent encoded characters.
   
   The W3C HTML5 specification, section 4.10.22.5 URL-encoded form
   data percent encodes all characters except the following:
   
   - Space (0x20) is replaced by a "+" (0x2B)
   - Bytes in the range 0x2A, 0x2D, 0x2E, 0x30-0x39, 0x41-0x5A, 0x5F, 0x61-0x7A
     (alphanumeric + "*-._")
   - Parameter plusForSpace: Boolean, when true replaces space with a '+'
   otherwise uses percent encoding (%20). Default is false.
   
   - Returns: The encoded string, or nil if the transformation is not possible.
   */

  public func stringByAddingPercentEncodingForFormData(plusForSpace: Bool=false) -> String {
    let unreserved = "*-._"
    let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
    allowedCharacterSet.addCharacters(in: unreserved)
    
    if plusForSpace {
        allowedCharacterSet.addCharacters(in: " ")
    }
    
    var encoded = addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet)
    if plusForSpace {
        encoded = encoded?.replacingOccurrences(of: " ", with: "+")
    }
    return encoded  ?? self
  }
}

public extension Dictionary where Key == String, Value == String {
    func httpParameters(includeQuestionMark: Bool = true) -> String {
        
        var p = ""
        if includeQuestionMark {
            p += "?"
        }
        
        forEach { p = p + "\($0.stringByAddingPercentEncodingForFormData())=\($1.stringByAddingPercentEncodingForFormData())&" }
        if p.last == "&" { p.removeLast() }
        return p
    }
}

// MARK: - cURLRepresentation
public extension URLRequest {
    func cURLRepresentation() -> String {
        var components = ["$ curl -v"]
        
        let request = self
        guard let url = request.url
            else {
                return "$ curl command could not be created"
        }
        
        if let httpMethod = request.httpMethod, httpMethod != "GET" {
            components.append("-X \(httpMethod)")
        }
        
        var headers: [AnyHashable: Any] = [:]
        request.allHTTPHeaderFields?.filter { $0.0 != "Cookie" }
            .forEach { headers[$0.0] = $0.1 }
        
        components += headers.map {
            let escapedValue = String(describing: $0.value).replacingOccurrences(of: "\"", with: "\\\"")
            
            return "-H \"\($0.key): \(escapedValue)\""
        }
        
        if let httpBodyData = request.httpBody, let httpBody = String(data: httpBodyData, encoding: .utf8) {
            let escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            components.append("-d '\(escapedBody)'")
        }
        
        components.append("\"\(url.absoluteString)\"")
        return components.joined(separator: " \\\n\t")
    }
}
