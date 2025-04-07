import Foundation
import JSON

public struct ChatRequest: Codable, Sendable {
    public var model: String
    public var messages: [Message]
    public var tools: [Tool]?
    public var tool_choice: ToolChoice?
    public var response_format: ResponseFormat?
    public var stream: Bool?
    public var repetition_penalty: Double?
    public var temperature: Double?
    public var top_p: Double?
    public var top_k: UInt?
    public var max_completion_tokens: UInt?

    public struct Message: Codable, Sendable {
        public var role: Role
        public var content: [Content]
        public var tool_call_id: String?
        public var tool_calls: [ToolCall]?
        public var stop_reason: String?

        public struct Content: Codable, Sendable {
            public var type: ContentType
            public var text: String?
            public var image_url: ImageURL?

            public enum ContentType: String, Codable, Sendable {
                case text
                case image
            }

            public struct ImageURL: Codable, Sendable {
                public var url: String

                public init(url: String) {
                    self.url = url
                }
            }

            public init(text: String) {
                self.type = .text
                self.text = text
            }

            public init(image url: String) {
                self.type = .image
                self.image_url = .init(url: url)
            }
        }

        public enum Role: String, Codable, Sendable {
            case system
            case user
            case assistant
            case tool
        }

        public init(role: Role, content: [Content], tool_call_id: String? = nil, tool_calls: [ToolCall]? = nil, stop_reason: String? = nil) {
            self.role = role
            self.content = content
            self.tool_call_id = tool_call_id
            self.tool_calls = tool_calls
            self.stop_reason = stop_reason
        }
    }

    public struct ResponseFormat: Codable, Sendable {
        public var type: String
        public var json_schema: Schema?

        public struct Schema: Codable, Sendable {
            public var name: String
            public var schema: JSONSchema

            public init(name: String, schema: JSONSchema) {
                self.name = name
                self.schema = schema
            }
        }

        public init(type: String, json_schema: Schema? = nil) {
            self.type = type
            self.json_schema = json_schema
        }
    }

    public init(model: String, messages: [Message], tools: [Tool]? = nil, tool_choice: ToolChoice? = nil,
                response_format: ResponseFormat? = nil, stream: Bool? = nil, repetition_penalty: Double? = nil,
                temperature: Double? = nil, top_p: Double? = nil, top_k: UInt? = nil, max_completion_tokens: UInt? = nil) {
        self.model = model
        self.messages = messages
        self.tools = tools
        self.tool_choice = tool_choice
        self.response_format = response_format
        self.stream = stream
        self.repetition_penalty = repetition_penalty
        self.temperature = temperature
        self.top_p = top_p
        self.top_k = top_k
        self.max_completion_tokens = max_completion_tokens
    }
}

public struct ChatResponse: Codable, Sendable {
    public let completion_message: CompletionMessage
    public let metrics: [Metric]?

    public struct CompletionMessage: Codable, Sendable {
        public let role: String
        public let content: Content
        public let stop_reason: String
        public let tool_calls: [ToolCall]?

        public struct Content: Codable, Sendable {
            public let type: String
            public let text: String?
            public let reasoning: String?
            public let answer: String?
        }
    }

    public struct Metric: Codable, Sendable {
        public let metric: String
        public let value: Double
        public let unit: String?
    }
}

public struct ChatStreamResponse: Codable, Sendable {
    public let event: Event

    public struct Event: Codable, Sendable {
        public let event_type: String
        public let delta: Delta?
        public let stop_reason: String?
        public let tool_calls: [ToolCall]?

        public struct Delta: Codable, Sendable {
            public let type: String

            // Content
            public let text: String?

            // Reasoning
            public let reasoning: String?
            public let answer: String?

            // Tool Call
            public let id: String?
            public let function: Function?

            public struct Function: Codable, Sendable {
                public let name: String?
                public let arguments: String?
            }
        }
    }
}
