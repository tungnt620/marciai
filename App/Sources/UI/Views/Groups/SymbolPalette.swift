import SwiftUI

struct SymbolPalette: View {
  private let symbols: [String] = [
    // AI-Related Symbols
        "brain.head.profile",     // AI thinking, machine learning
        "waveform.path.ecg",      // AI decision making, processing
        "lightbulb",              // AI innovation and ideas
        "chart.bar",              // AI analytics, insights
        "square.grid.3x3.fill",   // AI models (neural networks)
        "wand.and.stars",         // Automation, magic of AI
        "arrow.2.circlepath",     // Iterative learning, model training
        "sparkles",               // AI-related effects, magic
        "network",                // Neural networks, AI inference
        
      // General Developer/Tech Symbols
      "terminal",               // Command line, coding
      "laptopcomputer",         // General computer work
      "desktopcomputer",        // Desktop environment
      "keyboard",               // Typing and coding
      "gear",                   // Settings/configurations
      "hammer",                 // Building/Compiling
      "wrench",                 // Fixing, debugging
      "doc.text",               // Documentation
      "folder",                 // Project folder organization
      "filemenu.and.selection", // Menu/File management

      // Software Development
      "flowchart",              // Workflow design, flowcharting
      "server.rack",            // Backend server management
      "cpu",                    // CPU performance, resource usage
      "cloud",                  // Cloud services/Infrastructure
      "lock.shield",            // Security, data protection
      "shield.checkerboard",    // Security policies/checking

      // Project Management
      "calendar",               // Scheduling, deadlines
      "list.bullet",            // Task management
      "person.3",               // Team collaboration
      "person.crop.circle.badge.checkmark",  // Approvals/Quality assurance
      "chart.bar.doc.horizontal", // Reports/Project status
      "tray.full",              // Inbox/task tray
      "checkmark.seal",         // Verification
      "flag",                   // Milestones, important tasks
      "clock",                  // Time tracking, deadlines

      // Communication and Collaboration
      "message",                // Messaging/Communication
      "envelope",               // Email communication
      "bubble.left.and.bubble.right",  // Collaboration/Chat
      "video",                  // Video meetings
      "phone",                  // Calling, contact
      "person.2.wave.2",        // Collaboration, pair programming

      // Design and Prototyping
      "pencil.tip",             // UI/UX design
      "ruler",                  // Interface measurement
      "paintbrush",             // Design, creativity
      "rectangle.and.pencil.and.ellipsis", // Prototyping tools

      // Debugging and Testing
      "hammer.fill",            // Debugging/build tools
      "exclamationmark.triangle",  // Warnings/errors

      // DevOps/CI/CD
      "arrow.triangle.2.circlepath", // Continuous Integration/Deployment
      "arrow.down.doc",         // Importing/Downloading tools
      "arrow.up.doc",           // Uploading/Exporting tools
      "wrench.and.screwdriver", // DevOps, fixing infrastructure

      // Tools and Resources
      "book",                   // Learning, reading documentation
      "bookmark",               // Saving important resources
      "magnifyingglass",        // Searching through code, debugging

      // Task Completion/Review
      "checkmark.circle",       // Task completion
      "star.fill",              // Starred/favorite tasks
      "bolt.fill",              // Performance improvements

      // Collaboration and Communication
      "link",                   // Collaboration/linking to resources
      "globe",                  // Web development, internet usage
      "safari",                 // Web browser
      "wifi",                   // Connectivity, networking
      "airplane",               // Travel, remote work
    ]
  
  var items: [GridItem] {
    Array(repeating: .init(.fixed(size)), count: 5)
  }

  @Binding var group: WorkflowGroup
  var size: CGFloat

  var body: some View {
    LazyVGrid(columns: items, spacing: 10) {
      ForEach(symbols, id: \.self) { symbol in
        ZStack {
          Circle()
            .fill(Color(group.symbol == symbol ? .white : .clear))

          Circle()
            .fill(Color(.windowBackgroundColor))
            .frame(width: size, height: size)
            .overlay(
              Group {
                if !symbol.isEmpty {
                  Image(systemName: symbol)
                } else {
                  EmptyView()
                }
              }
            )
            .onTapGesture {
              group.symbol = symbol
            }
            .padding(2)
        }
      }
    }
  }
}

struct SymbolPalette_Previews: PreviewProvider {
  static var previews: some View {
    SymbolPalette(group: .constant(WorkflowGroup.designTime()), size: 32)
  }
}
