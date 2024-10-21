import Cocoa
import SwiftUI

class WindowAutoClodeWhenPressEsc: NSWindow {

  override func cancelOperation(_ sender: Any?) {
    // Close the window when Esc is pressed
    self.close()
  }
}

class WindowDisplayManager {
  
  @MainActor static func showResultWindow<Content: View>(
    identifier: String,
    title: String,
    contentView: Content,
    windowSize: CGSize = CGSize(width: 400, height: 400),
    bottomMargin: CGFloat = 100
  ) {
    if let existingWindow = NSApplication.shared.windows.first(where: { $0.identifier == NSUserInterfaceItemIdentifier(rawValue: identifier) }) {
      existingWindow.contentView = NSHostingController(rootView: contentView).view
      existingWindow.makeKeyAndOrderFront(nil)
      return
    }
    
    if let screen = NSScreen.main {
      let screenWidth = screen.frame.width
      let windowX = (screenWidth - windowSize.width) / 2
      
      let popupWindow = WindowAutoClodeWhenPressEsc(
        contentRect: NSRect(x: windowX, y: bottomMargin, width: windowSize.width, height: windowSize.height),
        styleMask: [.titled, .closable],
        backing: .buffered, defer: false
      )
      
      popupWindow.identifier = NSUserInterfaceItemIdentifier(rawValue: identifier)
      popupWindow.contentView = NSHostingController(rootView: contentView).view
      popupWindow.isReleasedWhenClosed = false
      popupWindow.level = .floating
      popupWindow.minSize = windowSize
      popupWindow.maxSize = windowSize
      popupWindow.title = title
      
      popupWindow.makeKeyAndOrderFront(nil)
    }
  }
}
