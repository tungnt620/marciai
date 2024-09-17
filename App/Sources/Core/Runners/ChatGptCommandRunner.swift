import Carbon
import Cocoa
import KeyCodes
import Foundation

final class ChatGptCommandRunner {
  private let keyboardCommandRunner: KeyboardCommandRunner

  internal init(_ keyboardCommandRunner: KeyboardCommandRunner) {
    self.keyboardCommandRunner = keyboardCommandRunner
  }

  func run(_ input: String) async throws {
      let pasteboard = NSPasteboard.general
      pasteboard.clearContents()
      pasteboard.setString(input, forType: .string)

      // TODO: add logic to call API and stream conent
    
      try await Task.sleep(for: .milliseconds(10))
      try keyboardCommandRunner.machPort?.post(kVK_ANSI_V, type: .keyDown, flags: .maskCommand)
      try keyboardCommandRunner.machPort?.post(kVK_ANSI_V, type: .keyUp, flags: .maskCommand)
      try await Task.sleep(for: .milliseconds(10))
  }
}
