import Foundation

public struct ModelsResponse: Codable {
    public let object: String
    public let data: [Model]
}

public struct Model: Codable {
    public let id: String
    public let object: String
    public let owned_by: String
    public let created: Int
}
