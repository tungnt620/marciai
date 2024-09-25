import Carbon
import Cocoa
import KeyCodes
import Foundation
import SwiftUI
import MarkdownUI
import Combine


final class ChatGptCommandRunner {
  private let keyboardCommandRunner: KeyboardCommandRunner
  
  internal init(_ keyboardCommandRunner: KeyboardCommandRunner) {
    self.keyboardCommandRunner = keyboardCommandRunner
  }
  
  func run(_ input: String) async throws {
    
    // Example usage
    //    let (focusedText, cursorPosition) = getFocusedText()
    //    if let text = focusedText {
    //      print("Collected Text: \(text)")
    //      if let cursorPos = cursorPosition {
    //        print("Cursor Position: \(cursorPos)")
    //      }
    //    }
    
    try await simulateCopyShortcut()
    
    // Update UI on the main actor
    await MainActor.run {
      let pasteboard = NSPasteboard.general
      // Get the string from the pasteboard if available
      let selectexText =  pasteboard.string(forType: .string)
      
      print(selectexText ?? "")
      
      showChatGptResultWindow(input: input, selectexText: selectexText ?? "")
    }
  }
  
  func simulateCopyShortcut() async  throws{
    try await Task.sleep(for: .milliseconds(10))
    try keyboardCommandRunner.machPort?.post(kVK_ANSI_C, type: .keyDown, flags: .maskCommand)
    try keyboardCommandRunner.machPort?.post(kVK_ANSI_C, type: .keyUp, flags: .maskCommand)
    try await Task.sleep(for: .milliseconds(10))
    try keyboardCommandRunner.machPort?.post(kVK_ANSI_C, type: .keyDown, flags: .maskCommand)
    try keyboardCommandRunner.machPort?.post(kVK_ANSI_C, type: .keyUp, flags: .maskCommand)
    try await Task.sleep(for: .milliseconds(30))
  }
}

// Function to get focused text and cursor position
func getFocusedText() -> (String?, Int?) {
  // Get the system-wide accessibility element
  let systemWideElement = AXUIElementCreateSystemWide()
  
  // Get the focused application
  var focusedElement: CFTypeRef?
  let elementResult = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
  
  
  guard elementResult == .success, let element = focusedElement else {
    return ("", 0)
  }
  
  // Retrieve the selected text from the focused element
  var selectedText: CFTypeRef?
  let textResult = AXUIElementCopyAttributeValue(element as! AXUIElement, kAXValueAttribute as CFString, &selectedText)
  
  if textResult == .success, let text = selectedText as? String {
    
    // Optionally get the cursor position
    var selectedRangeValue: CFTypeRef?
    let rangeResult = AXUIElementCopyAttributeValue(element as! AXUIElement, kAXSelectedTextRangeAttribute as CFString, &selectedRangeValue)
    
    if rangeResult == .success, let range = selectedRangeValue {
      var cursorPosition = CFRange()
      if AXValueGetValue(range as! AXValue, .cfRange, &cursorPosition) {
        return (text, cursorPosition.location)
      }
    }
    return (text, nil)
  }
  
  return (nil, nil)
}


func getSelectedText2() -> String {
  // Get the system-wide accessibility element (the current application)
  let systemWideElement = AXUIElementCreateSystemWide()
  
  // Get the element that has the keyboard focus (presumably where the user has selected text)
  var focusedElement: CFTypeRef?
  let result = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
  
  guard result == .success, let element = focusedElement else {
    return ""
  }
  
  // Retrieve the selected text from the focused element
  var selectedText: CFTypeRef?
  let textResult = AXUIElementCopyAttributeValue(element as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedText)
  
  
  if textResult == .success, let text = selectedText as? String {
    return text
  }
  
  return ""
}

func getSelectedText() -> NSAttributedString? {
  // Get the system-wide accessibility element (the current application)
  let systemWideElement = AXUIElementCreateSystemWide()
  
  // Get the element that has the keyboard focus (presumably where the user has selected text)
  var focusedElement: CFTypeRef?
  let result = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
  
  guard result == .success, let element = focusedElement else {
    return nil
  }
  
  // Retrieve the selected text (plain text)
  var selectedText: CFTypeRef?
  let textResult = AXUIElementCopyAttributeValue(element as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedText)
  
  // If plain text is available, return it as a fallback
  if textResult == .success, let text = selectedText as? String {
    return NSAttributedString(string: text)
  }
  
  // Attempt to retrieve attributed (rich) text if available
  var attributedText: CFTypeRef?
  let attributedTextResult = AXUIElementCopyAttributeValue(element as! AXUIElement, kAXAttributedStringForRangeParameterizedAttribute as CFString, &attributedText)
  
  if attributedTextResult == .success, let richText = attributedText as? NSAttributedString {
    return richText
  }
  
  return nil
}

func runAppleScript(text: String) {
  let lines = text.components(separatedBy: "\n")
  
  var appleScript = "tell application \"System Events\"\n"
  
  for (index, line) in lines.enumerated() {
    for char in line {
      switch char {
      case "\t": // Handle tabs
        appleScript += "key code 48\n" // Tab key
      case " ":
        appleScript += "key code 49\n" // Space key
      case "\u{8}": // Handle backspace
        appleScript += "key code 51\n" // Backspace key (Delete)
      case "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "+": // Special characters requiring Shift
        appleScript += "key down shift\n"
        appleScript += "keystroke \"\(char)\"\n"
        appleScript += "key up shift\n"
      case "\u{1B}": // Handle Escape (ASCII escape)
        appleScript += "key code 53\n" // Escape key
      default:
        appleScript += "keystroke \"\(char)\"\n" // Regular characters
      }
    }
    if index < lines.count - 1 {
      appleScript += "key code 36\n" // New line (Return key)
    }
  }
  
  appleScript += "end tell"
  
  var error: NSDictionary?
  if let scriptObject = NSAppleScript(source: appleScript) {
    scriptObject.executeAndReturnError(&error)
  }
  
  if let error = error {
    print("AppleScript Error: \(error)")
  }
}

@MainActor
class MarkdownStreamModel: ObservableObject {
  @Published var markdownContent: String = "" {
    didSet {
      triggerThrottledUpdate()
    }
  }
  
  // This stores the cancellable to ensure we can cancel previous throttle requests
  private var throttleCancellable: AnyCancellable?
  
  // Publisher to debounce the updates
  private let throttleDelay = 0.5
  
  func streamMarkdown(_ input: String, _ selectedText: String) {
    let apiKey = "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" // Replace with your actual API key
    let client = ChatGPTClient(apiKey: apiKey)
    
    let messages: [[String: Any]] = [
      ["role": "system", "content": "You are a helpful assistant."],
      ["role": "user", "content": "\(input)\n\nInput: \(selectedText)"]
    ]
    
    client.startChat(with: messages, onMessageReceived: { chunk, stopChat in
      // Make sure to update the UI on the main thread
      DispatchQueue.main.async {
        self.markdownContent.append(chunk)
      }
    }, onError: { error in
      // Custom logic to handle errors
      print("Error: \(error)")
    })
  }
  
  // Method to throttle updates
  func triggerThrottledUpdate() {
    throttleCancellable?.cancel()  // Cancel any existing throttle request
    throttleCancellable = Just(markdownContent)
      .delay(for: .seconds(throttleDelay), scheduler: RunLoop.main)
      .sink { [weak self] newValue in
        self?.objectWillChange.send()  // Send update notification
      }
  }
}

struct PopupView: View {
  @StateObject var viewModel = MarkdownStreamModel()  // Ensure proper lifecycle management
  
  let input: String
  let selectedText: String
  @State private var showCopiedText = false  // State to control "Copied!" message visibility
  
  var body: some View {
    ZStack(alignment: .bottomTrailing) {  // Use ZStack to overlay the button in the bottom-right
      
      ScrollView {
        CodeSyntaxHighlightView(markdownContent: viewModel.markdownContent)
          .padding()
          .textSelection(.enabled)
          .frame(maxWidth: .infinity)  // Allow content to grow horizontally
      }
      .clipped()  // Ensure content is clipped to fit within the scroll view
      .onAppear {
        viewModel.streamMarkdown(input, selectedText)  // Trigger markdown fetching
      }
      
      VStack(alignment: .center) {
        // "Copied!" helper text
        if showCopiedText {
          Text("Copied!")
            .font(.caption)
            .foregroundColor(.green)
            .transition(.opacity)  // Fade in/out
            .padding(.bottom, 8)
        }
        
        // Copy-to-clipboard button
        Button(action: {
          copyToClipboard(markdownContent: viewModel.markdownContent)  // Copy markdown content
          showCopiedFeedback()  // Show "Copied!" message
        }) {
          Image(systemName: "doc.on.doc")  // Clipboard icon
            .resizable()
            .frame(width: 12, height: 12)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)  // Button background color
            .cornerRadius(8)
            .shadow(radius: 3)  // Add shadow for depth
        }
        .buttonStyle(PlainButtonStyle())  // Ensure no default button style interferes
        .padding(.trailing)
        .padding(.bottom)
      }
    }
  }
  
  // Function to copy markdown content to the clipboard
  func copyToClipboard(markdownContent: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()  // Clear any existing content
    pasteboard.declareTypes([.html, .string], owner: nil)
    let plainTextContent = MarkdownContent(markdownContent).renderPlainText()
    let htmlContent = MarkdownContent(markdownContent).renderHTML()
    
    // Add both plain text and html for fallback, some application only
    // support plain text
    
    if let data = htmlContent.data(using: .utf8) {
      print("String converted to Data: \(data)")
      pasteboard.setData(data, forType: .html)
    } else {
      print("Failed to convert string to Data")
    }
    
    if let data = plainTextContent.data(using: .utf8) {
      print("String converted to Data: \(data)")
      pasteboard.setData(data, forType: .string)
    } else {
      print("Failed to convert string to Data")
    }
  }
  
  // Function to show "Copied!" helper text for a short duration
  func showCopiedFeedback() {
    withAnimation {
      showCopiedText = true  // Show the "Copied!" text with animation
    }
    
    // Hide the message after 2 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      withAnimation {
        showCopiedText = false
      }
    }
  }
}

class ChatGptResultWindow: NSWindow {
  
  override func cancelOperation(_ sender: Any?) {
    // Close the window when Esc is pressed
    self.close()
  }
}

@MainActor
func showChatGptResultWindow(input: String, selectexText: String) {
  
  // Create the SwiftUI view that provides the popup content
  let popupView = NSHostingController(rootView: PopupView(input: input, selectedText: selectexText))
  
  
  // Check if the window is already created
  if let existingWindow = NSApplication.shared.windows.first(where: { $0.identifier == NSUserInterfaceItemIdentifier(rawValue: "chatGptResultWindow") }) {
    existingWindow.contentView = popupView.view
    existingWindow.makeKeyAndOrderFront(nil) // Bring existing window to the front
    return
  }
  
  // Get the main screen size
  if let screen = NSScreen.main {
    let screenWidth = screen.frame.width
    
    // Define the window size
    let windowWidth: CGFloat = 400
    let windowHeight: CGFloat = 400
    
    // Define the bottom margin
    let bottomMargin: CGFloat = 100  // Space from the bottom of the screen
    
    // Calculate the X and Y position for the bottom center
    let windowX = (screenWidth - windowWidth) / 2
    
    // Create a new window and set the content
    let popupWindow = ChatGptResultWindow(
      contentRect: NSRect(x: windowX, y: bottomMargin, width: windowWidth, height: windowHeight),
      styleMask: [.titled, .closable],
      backing: .buffered, defer: false
    )
    
    // Hide Zoom and Minimize buttons
    if let zoomButton = popupWindow.standardWindowButton(.zoomButton) {
      zoomButton.isHidden = true
    }
    
    if let minimizeButton = popupWindow.standardWindowButton(.miniaturizeButton) {
      minimizeButton.isHidden = true
    }
    
    popupWindow.identifier = NSUserInterfaceItemIdentifier(rawValue: "chatGptResultWindow")
    popupWindow.contentView = popupView.view
    popupWindow.canHide = true
    popupWindow.isReleasedWhenClosed = false // Keep the window alive even if closed
    popupWindow.level = .floating // Ensure it stays on top of other windows
    popupWindow.minSize = NSSize(width: windowWidth, height: windowHeight)  // Minimum size for the window
    popupWindow.maxSize = NSSize(width: windowWidth, height: windowHeight)  // Maximum size for the window
    
    popupWindow.makeKeyAndOrderFront(nil)
  }
}
