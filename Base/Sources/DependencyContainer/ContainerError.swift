import Foundation

public class ContainerError: Error, CustomDebugStringConvertible {
    public let type: Message
    private let filename: String
    private let method: String
    private let line: Int

    public init(_ type: Message, path: String = #file, function: String = #function, line: Int = #line) {
        if let file = path.split(separator: "/").last {
            filename = String(file)
        } else {
            filename = path
        }
        method = function
        self.line = line
        self.type = type
    }

    open var debugDescription: String { "\(filename):\(line) - \(method) => \(type.message)" }

    public enum Message {
        case notFound

        var message: String {
            "No dependency registered for please use @Register property wrapper to specify what you want to inject."
        }
    }
}
