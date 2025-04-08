<img src="Echo.png" width="256">

# Swift Llama

A Swift client library for interacting with Meta's [Llama API](https://llama.developer.meta.com).

## Requirements

- Swift 5.9+
- iOS 16+
- macOS 13+
- watchOS 9+
- tvOS 16+

## Installation

Add the following to your `Package.swift` file:

```swift
Package(
    dependencies: [
        .package(url: "https://github.com/nathanborror/swift-llama", branch: "main"),
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: [
                .product(name: "Llama", package: "swift-llama"),
            ]
        ),
    ]
)
```

## Usage

### Chat Completion

```swift
import Llama

let client = Client(apiKey: LLAMA_API_KEY)

let request = ChatRequest(
    model: "Llama-4-Scout-17B-16E-Instruct-FP8",
    messages: [
        .init(role: .system, content: [.init(text: "You are a helpful llama.")]),
        .init(role: .user, content: [.init(text: "Hello, Llama!")])
    ]
)

do {
    let response = try await client.chatCompletions(request)
    print(response.completion_message.content.text)
} catch {
    print(error)
}
```

### List Models

```swift
import Llama

let client = Client(apiKey: LLAMA_API_KEY)

do {
    let response = try await client.models()
    print(response.data.map { $0.id }.joined(separator: "\n"))
} catch {
    print(error)
}
```

### Command Line Interface

    $ make
    $ ./llama
    OVERVIEW: A utility for interacting with Meta's Llama API.

    USAGE: cli <subcommand>

    OPTIONS:
      --version               Show the version.
      -h, --help              Show help information.

    SUBCOMMANDS:
      models                  Returns available models.
      chat                    Completes a chat request.
      chat-stream             Completes a chat streaming request.

      See 'cli help <subcommand>' for detailed help.
