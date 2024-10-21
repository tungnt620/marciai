import Carbon
import Cocoa
import KeyCodes
import Foundation
import SwiftUI
import MarkdownUI
import Combine


@MainActor
func runChatGptForCommandRunner(_ input: String, _ chatGptApiKey: String) async throws {
    // Fetch the selected text from the pasteboard
  let selectedText = fetchSelectedTextFromPasteboard()
  
  print("selected text \(selectedText)")
  
  let canCall = canCallChatGptApi(chatGptApiKey: chatGptApiKey)
  if canCall {
    showChatGptResultWindow(input: input, selectedText: selectedText)
  }
}

func canCallChatGptApi(chatGptApiKey: String) -> Bool {
  // Check if the user has set their own API key or is using a free limit
  if chatGptApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
    // Check if the user can still make API calls
    if GlobalUtils.shared.apiLimiter.canMakeApiCall() {
      // Insert an event to track usage
      Task {
        await GlobalUtils.shared.insertEvent(event: Event(action_type: "use_tom_chatgpt_key"))
      }
      
      return true
    } else {
      // If the API limit is reached, show a limit alert window
      Task {
        await GlobalUtils.shared.insertEvent(event: Event(action_type: "no_more_usage"))
      }
      return false
    }
  } else {
    // If the user has set their own API key, proceed with showing the result
    Task {
      await GlobalUtils.shared.insertEvent(event: Event(action_type: "use_own_chatgpt_key"))
    }
    return true
  }
}



// Function to show the ChatGPT result in a window using the reusable view and window logic
@MainActor
func showChatGptResultWindow(input: String, selectedText: String) {
  let contentView = ChatGptResultView(input: input, selectedText: selectedText)
  WindowDisplayManager.showResultWindow(
    identifier: "chatGptResultWindow",
    title: "ChatGPT Result",
    contentView: contentView
  )
}

// Function to show the limit alert window
@MainActor
func showLimitAlertWindow() {
  let contentView = ReachApiLimitView()
  WindowDisplayManager.showResultWindow(
    identifier: "limitAlertWindow",
    title: "API Limit Reached",
    contentView: contentView
  )
}

struct ReachApiLimitView: View {
  @Namespace var namespace
  
  var body: some View {
    ZStack(alignment: .bottomTrailing) {  // Use ZStack to overlay the button in the bottom-right
      VStack {
        Grid(alignment: .center, horizontalSpacing: 16, verticalSpacing: 32) {
          VStack(alignment: .leading) {
            Text("You have reached the usage limit")
              .font(.headline)
              .bold()
            
            Text("""
                 The usage limit is 50 AI generations per 7 days. It will reset after 7 days.
                 Please consider the following options:\n
                 """)
            .font(.caption)
            
            Text("""
                 1. Use your own ChatGPT API key. You can find the guide at https://marciai.app/faq#how-to-get-chatgpt-api-key.\n
                 """)
            .font(.caption)
            
            Text("""
                 2. Enjoy unlimited usage with a subscription, which will be more affordable than purchasing a ChatGPT account.
                 This feature is coming soon. Stay updated at https://marciai.app/faq#how-to-use-without-chatgpt-api-key.\n
                 """)
            .font(.caption)
            
            Text("""
                 3. Provide feedback to earn additional usage. Reach us at tom@marciai.app. We are more than happy to hear from you!
                 """)
            .font(.caption)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .roundedContainer()
      .frame(minWidth: 480, maxWidth: 480)
    }
  }
}

