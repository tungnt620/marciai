import Combine
import SwiftUI

@MainActor
class ChatGptResultViewModel: ObservableObject {
  @AppStorage("Setting.chatGptApiKey") var chatGptApiKey: String = ""
  @Published var markdownContent: String = ""
  private var throttleCancellable: AnyCancellable?
  private let throttleDelay = 0.5
  
  func fetchChatGptResult(input: String, selectedText: String) {
    var apiKey = chatGptApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    if apiKey.isEmpty {
      apiKey = GlobalUtils.myApiKey
    }
    
    let client = ChatGPTClient(apiKey: apiKey)
    let messages: [[String: Any]] = [
      ["role": "system", "content": "You are a helpful assistant that responds in Markdown."],
      ["role": "user", "content": "\(input)\n\nInput: \(selectedText)"]
    ]
    
    client.startChat(
      with: messages,
      onMessageReceived: { [weak self] chunk, _ in
        Task { @MainActor in
          self?.markdownContent.append(chunk)
        }
      },
      onError: { error in
        print("Error: \(error)")
        Task {
          try await GlobalUtils.shared.insertEvent(event: Event(action_type: "error_from_chatgpt", detail: error.asString()))
        }
      }
    )
  }
  
  func triggerThrottledUpdate() {
    throttleCancellable?.cancel()
    throttleCancellable = Just(markdownContent)
      .delay(for: .seconds(throttleDelay), scheduler: RunLoop.main)
      .sink { [weak self] _ in
        self?.objectWillChange.send()
      }
  }
}