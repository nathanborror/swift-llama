import Foundation
import JSON

public struct Tool: Codable, Sendable {
    public var type: String
    public var function: Function

    public struct Function: Codable, Sendable {
        public var name: String
        public var description: String?
        public var parameters: JSONSchema?
        public var strict: Bool?

        public init(name: String, description: String? = nil, parameters: JSONSchema? = nil, strict: Bool? = nil) {
            self.name = name
            self.description = description
            self.parameters = parameters
            self.strict = strict
        }
    }

    public init(type: String, function: Function) {
        self.type = type
        self.function = function
    }
}

public struct ToolChoice: Codable, Sendable {
    public var type: String
    public var function: Function

    public struct Function: Codable, Sendable {
        public var name: String

        public init(name: String) {
            self.name = name
        }
    }

    public init(type: String, function: Function) {
        self.type = type
        self.function = function
    }
}

public struct ToolCall: Codable, Sendable {
    public var id: String
    public var function: Function

    public struct Function: Codable, Sendable {
        public var name: String
        public var arguments: String

        public init(name: String, arguments: String) {
            self.name = name
            self.arguments = arguments
        }
    }

    public init(id: String, function: Function) {
        self.id = id
        self.function = function
    }
}
