import Foundation

struct APIConfig {
    struct OpenAI {
        static let chatCompletionsURL = "https://api.openai.com/v1/chat/completions"
        static let model = "gpt-3.5-turbo"
        static let temperature: Double = 0.3
        static let maxTokens = 1000
        static let seed = 6
    }
}