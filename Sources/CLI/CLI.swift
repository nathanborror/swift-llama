import Foundation
import ArgumentParser
import Llama

@main
struct CLI: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "llama",
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
        guard let model = global.model else {
            fatalError("Missing model argument")
        }
        let client = Llama.Client(apiKey: global.key)
        let request = ChatRequest(model: model, messages: [.init(role: .user, content: [.init(text: prompt)])])
        let resp = try await client.chatCompletions(request)

        if let reasoning = resp.completion_message.content.reasoning, let data = reasoning.data(using: .utf8) {
            FileHandle.standardOutput.write("<reasoning>".data(using: .utf8)!)
            FileHandle.standardOutput.write(data)
            FileHandle.standardOutput.write("</reasoning>\n\n".data(using: .utf8)!)
        }
        if let answer = resp.completion_message.content.answer, let data = answer.data(using: .utf8) {
            FileHandle.standardOutput.write("<answer>".data(using: .utf8)!)
            FileHandle.standardOutput.write(data)
            FileHandle.standardOutput.write("\n</answer>".data(using: .utf8)!)
        }
        if let text = resp.completion_message.content.text, let data = text.data(using: .utf8) {
            FileHandle.standardOutput.write(data)
        }
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
        let request = ChatRequest(model: model, messages: [.init(role: .user, content: [.init(text: prompt)])], stream: true)

        for try await resp in try client.chatCompletionsStream(request) {

            // Reasoning
            if let text = resp.event.delta.reasoning, let data = text.data(using: .utf8) {
                FileHandle.standardOutput.write(data)
            }
            if let text = resp.event.delta.answer, let data = text.data(using: .utf8) {
                FileHandle.standardOutput.write(data)
            }

            // Content
            if let text = resp.event.delta.text, let data = text.data(using: .utf8) {
                FileHandle.standardOutput.write(data)
            }

            // Tool Call
            if let name = resp.event.delta.function?.name, let data = name.data(using: .utf8) {
                FileHandle.standardOutput.write(data)
            }
            if let arguments = resp.event.delta.function?.arguments, let data = arguments.data(using: .utf8) {
                FileHandle.standardOutput.write(data)
            }
        }
    }
}
