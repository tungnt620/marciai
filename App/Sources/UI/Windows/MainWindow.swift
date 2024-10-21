import Bonzai
import SwiftUI
import Combine

struct MainWindow: Scene {
  private let core: Core
  @FocusState var focus: AppFocus?

  @Environment(\.openWindow) private var openWindow
  private let onScene: (AppScene) -> Void

  @StateObject private var textSelectionObserver = TextSelectionObserver.shared
  @State private var floatingPanelController: FloatingPanelController?
  @State private var cancellables = Set<AnyCancellable>() // To store Combine subscriptions

  init(_ core: Core, onScene: @escaping (AppScene) -> Void) {
    self.core = core
    self.onScene = onScene
  }

  var body: some Scene {
    WindowGroup(id: KeyboardCowboy.mainWindowIdentifier) {
      MainWindowView($focus, core: core, onSceneAction: {
        onScene($0)
      })
      .animation(.easeInOut, value: core.contentStore.state)
      .onAppear {
        NSWindow.allowsAutomaticWindowTabbing = false
        
        // Initialize the floating panel but keep it hidden initially
        floatingPanelController = FloatingPanelController(
          $focus,
          core,
          onScene: {
            onScene($0)
          },
          textSelectionObserver: textSelectionObserver
        )
        
        // Listen for changes in text selection and update panel visibility
        textSelectionObserver.$currentSelectedText.sink { _ in
          floatingPanelController?.updatePanelVisibility()
        }
        .store(in: &cancellables)
      }
      
    }
    .windowResizability(.contentSize)
    .windowStyle(.hiddenTitleBar)
    .commands {
//      CommandGroup(after: .appSettings) {
//        AppMenu()
//        Button { openWindow(id: KeyboardCowboy.releaseNotesWindowIdentifier) } label: { Text("What's new?") }
//      }
      CommandGroup(replacing: .newItem) {
        FileMenu(
          onNewConfiguration: {
            let action = SidebarView.Action.addConfiguration(name: "New Configuration")
            core.configCoordinator.handle(action)
            core.sidebarCoordinator.handle(action)
            core.contentCoordinator.handle(action)
            core.detailCoordinator.handle(action)
          },
          onNewGroup: { onScene(.addGroup) },
          onNewWorkflow: {
            let action = ContentView.Action.addWorkflow(workflowId: UUID().uuidString)
            core.contentCoordinator.handle(action)
            core.detailCoordinator.handle(action)
            focus = .detail(.name)
          },
          onNewCommand: { id in
            onScene(.addCommand(id))
          }
        )
        .environmentObject(core.contentStore.groupStore)
        .environmentObject(core.detailCoordinator.statePublisher)
        .environmentObject(core.detailCoordinator.infoPublisher)
      }

      CommandGroup(replacing: .toolbar) {
        ViewMenu(onFilter: {
          focus = .search
        })
      }

//      CommandGroup(replacing: .help) {
//        HelpMenu()
//      }
    }
  }
}
