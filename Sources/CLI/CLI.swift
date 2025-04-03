import Foundation
import ArgumentParser
import Llama

@main
struct CLI: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "A utility for interacting with Meta's Llama API.",
        version: "0.0.1",
        subcommands: [
            Models.self,
            ChatCompletion.self,
            ChatStreamCompletion.self,
        ]
    )
}

struct GlobalOptions: ParsableCommand {
    @Option(name: .shortAndLong, help: "Your API key.")
    var key: String

    @Option(name: .shortAndLong, help: "Model to use.")
    var model: String?
}

struct Models: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "models",
        abstract: "Returns available models."
    )

    @OptionGroup
    var global: GlobalOptions

    func run() async throws {
        let client = Llama.Client(apiKey: global.key)
        let resp = try await client.models()
        print(resp.data.map { $0.id }.joined(separator: "\n"))
    }
}

struct ChatCompletion: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "chat",
        abstract: "Completes a chat request."
    )

    @OptionGroup
    var global: GlobalOptions

    @Option(name: .long, help: "Chat prompt.")
    var prompt: String

    func run() async throws {
        guard let model = global.model else { return }

        let client = Llama.Client(apiKey: global.key)
        let request = ChatRequest(model: model, messages: [.init(role: .user, content: prompt)])
        let resp = try await client.chatCompletions(request)
        print(resp)
    }
}

struct ChatStreamCompletion: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "chat-stream",
        abstract: "Completes a chat streaming request."
    )

    @OptionGroup
    var global: GlobalOptions

    @Option(name: .long, help: "Chat prompt.")
    var prompt: String

    func run() async throws {
        guard let model = global.model else { return }

        let client = Llama.Client(apiKey: global.key)
        let request = ChatRequest(model: model, messages: [.init(role: .user, content: prompt)], stream: true)

        for try await resp in try client.chatCompletionsStream(request) {
            print(resp)
        }
    }
}
