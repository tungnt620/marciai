import Cocoa
import SwiftUI

class FloatingButtonController: NSWindowController {
  @ObservedObject var textSelectionObserver: TextSelectionObserver
  
  private let core: Core
  private var focus: FocusState<AppFocus?>.Binding
  private let onScene: (AppScene) -> Void
  
  @State private var showPopover = true // State to control popover visibility
  
  init(_ focus: FocusState<AppFocus?>.Binding, _ core: Core, onScene: @escaping (AppScene) -> Void, textSelectionObserver: TextSelectionObserver) {
    self.core = core
    self.onScene = onScene
    self.textSelectionObserver = textSelectionObserver
    self.focus = focus
    
    let panel = NSPanel(
      contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered, defer: true
    )
    
    // Get the screen size (use the main screen for centering)
    if let screen = NSScreen.main {
      let screenFrame = screen.frame
      
      // Calculate the center position
      let panelWidth: CGFloat = 40
      let panelHeight: CGFloat = 40
      let panelX = (screenFrame.width - panelWidth) / 2
      
      // Set the frame of the panel to be in the center of the screen
      panel.setFrame(NSRect(x: panelX, y: 100, width: panelWidth, height: panelHeight), display: true)
    }
    
    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.level = .floating // Ensure it floats above all other windows
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    panel.hasShadow = true
    
    // Make the panel movable by dragging its background
    panel.isMovableByWindowBackground = true
    
    // Create an NSHostingView to wrap the SwiftUI view
    let hostingView = NSHostingView(rootView: SimplePopoverExample(focus, core, onScene: onScene))
    
    // Set the NSHostingView as the content view for the panel
    panel.contentView = hostingView
    
    // Automatically adjust the panel size to fit its content
    panel.contentView?.invalidateIntrinsicContentSize()
    panel.contentView?.translatesAutoresizingMaskIntoConstraints = false
    
    super.init(window: panel)
    
    // Force the panel to fit the content by setting size constraints
    NSLayoutConstraint.activate([
      hostingView.widthAnchor.constraint(equalToConstant: hostingView.intrinsicContentSize.width),
      hostingView.heightAnchor.constraint(equalToConstant: hostingView.intrinsicContentSize.height)
    ])

  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Dynamically adjust the panel's position and size
  func updatePanelVisibility() {
    DispatchQueue.main.async {
      if !self.textSelectionObserver.currentSelectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        self.window?.orderFront(nil) // Show the panel
      } else {
        self.window?.orderOut(nil) // Hide the panel if no text is selected
      }
    }
  }
}

struct SimplePopoverExample: View {
  @State private var showPopover = true // Set to true initially
  
  
  private let core: Core
  private var focus: FocusState<AppFocus?>.Binding
  private let onScene: (AppScene) -> Void
  
  
  init(_ focus: FocusState<AppFocus?>.Binding, _ core: Core, onScene: @escaping (AppScene) -> Void) {
    self.core = core
    self.onScene = onScene
    self.focus = focus
  }
  
  var body: some View {
    VStack {
      Button(action: {
          self.showPopover = true // Show the popover when the button is clicked
      }) {
          Image(systemName: "wand.and.stars") // Use SF Symbols or a custom image
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 30, height: 30) // Set the size of the icon
      }
      .background(.clear)
      .padding(0)
      .frame(width: 35, height: 35)
      .buttonStyle(.zen(.init(hoverEffect: .constant(false))))
      .popover(isPresented: $showPopover) {
        CommandCenterView(focus, core: core, onSceneAction: onScene)
          .frame(minWidth: 700, minHeight: 400)
      }
    }
    .padding()
  }
}
