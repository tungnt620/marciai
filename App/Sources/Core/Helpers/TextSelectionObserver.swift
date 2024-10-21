import Cocoa
import SwiftUI
import Combine

class TextSelectionObserver: ObservableObject {
  // Shared instance for singleton
  static let shared = TextSelectionObserver()
  
  @Published var currentSelectedText: String = ""
  private var globalEventMonitor: Any? // Store the global event monitor reference
  private var cancellables = Set<AnyCancellable>()
  private var isGlobalEventMonitorEnabled = false
  
  // Private initializer to prevent additional instances
  private init() {
    // Optionally initialize any necessary behavior here
  }
  
  // Enable the global event monitor
  func enableGlobalEventMonitor() {
    guard !isGlobalEventMonitorEnabled else { return } // Prevent enabling multiple times
    
    let eventMask: NSEvent.EventTypeMask = [.leftMouseUp, .leftMouseDown, .keyUp, .keyDown]
    globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { (event) in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.updateSelectedText()
      }
    }
    isGlobalEventMonitorEnabled = true
    print("Global event monitor enabled.")
  }
  
  // Disable the global event monitor
  func disableGlobalEventMonitor() {
    if let monitor = globalEventMonitor {
      NSEvent.removeMonitor(monitor)
      globalEventMonitor = nil
      isGlobalEventMonitorEnabled = false
      print("Global event monitor disabled.")
    }
  }
  
  // Update the selected text and its bounds
   func updateSelectedText() {
       let text = getSelectedText()
       DispatchQueue.main.async {
         self.currentSelectedText = text
       }
   }
}

// Function to get focused text and cursor position
func getSelectedText() -> String {
  // Get the system-wide accessibility element
  let systemWideElement = AXUIElementCreateSystemWide()
  
  // Get the focused application
  var focusedElement: CFTypeRef?
  let elementResult = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
  
  guard elementResult == .success, let element = focusedElement else {
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
