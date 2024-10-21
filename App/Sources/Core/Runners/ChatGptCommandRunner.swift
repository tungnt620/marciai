import SwiftUI


final class ChatGptCommandRunner {
  private let keyboardCommandRunner: KeyboardCommandRunner
  @AppStorage("Setting.chatGptApiKey") var chatGptApiKey: String = ""
  
  internal init(_ keyboardCommandRunner: KeyboardCommandRunner) {
    self.keyboardCommandRunner = keyboardCommandRunner
  }
  
  func run(_ input: String) async throws {
    try await simulateCopyShortcut(keyboardCommandRunner: keyboardCommandRunner)
    try await runChatGptForCommandRunner(input, chatGptApiKey)
  }
}
