import Cocoa
import SwiftUI


class FloatingPanelController: NSWindowController {
  @ObservedObject var textSelectionObserver: TextSelectionObserver
  
  private let core: Core
  private var focus: FocusState<AppFocus?>.Binding
  private let onScene: (AppScene) -> Void
  
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
      let panelWidth: CGFloat = 800
      let panelHeight: CGFloat = 500
      let panelX = (screenFrame.width - panelWidth) / 2
      
      // Set the frame of the panel to be in the center of the screen
      panel.setFrame(NSRect(x: panelX, y: 100, width: panelWidth, height: panelHeight), display: true)
    }
    
    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.level = .floating // Ensure it floats above all other windows
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    
    super.init(window: panel)
    
    // Enable the default shadow
    panel.hasShadow = true
    
    // Make the panel movable by dragging its background
    panel.isMovableByWindowBackground = true
    
    // Create a content view using CommandCenterView (which is a SwiftUI view)
    let contentView = CommandCenterView(focus, core: core, onSceneAction: onScene)
      .padding()
      .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(.background)
              .shadow(radius: 10)
      )
      .padding()
    
    // Create an NSHostingView to wrap the SwiftUI view
    let hostingView = NSHostingView(rootView: contentView)
    
    // Set the NSHostingView as the content view for the panel
    panel.contentView = hostingView
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

// Define the SwiftUI button that will appear in the floating panel
struct FloatingButtonView: View {
  @State private var showPanel = false // State to control panel visibility

  
  
  var body: some View {
    Button(action: {
      print("Floating button clicked!")
    }) {
      Text("Click Me")
        .padding()
        .background(Color.blue.opacity(0.8))
        .foregroundColor(.white)
        .cornerRadius(10)
    }
    .shadow(radius: 5)
    .padding()
    .sheet(isPresented: $showPanel) { // Present the panel as a sheet
        PanelView(showPanel: $showPanel)
    }
  }
}
