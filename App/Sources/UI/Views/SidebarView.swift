import Bonzai
import SwiftUI

struct SidebarView: View {
  enum Action {
    case refresh
    case openScene(AppScene)
    case addConfiguration(name: String)
    case userMode(UserModesView.Action)
    case updateConfiguration(name: String)
    case deleteConfiguration(id: ConfigurationViewModel.ID)
    case selectConfiguration(ConfigurationViewModel.ID)
    case selectGroups(Set<GroupViewModel.ID>)
    case moveGroups(source: IndexSet, destination: Int)
    case removeGroups(Set<GroupViewModel.ID>)
    case moveWorkflows(workflowIds: Set<ContentViewModel.ID>, groupId: GroupViewModel.ID)
    case copyWorkflows(workflowIds: Set<ContentViewModel.ID>, groupId: GroupViewModel.ID)
  }
  
  @Environment(\.openURL) var openURL
  @EnvironmentObject private var publisher: GroupsPublisher
  @Namespace private var namespace
  private let configSelectionManager: SelectionManager<ConfigurationViewModel>
  private let contentSelectionManager: SelectionManager<ContentViewModel>
  private let groupSelectionManager: SelectionManager<GroupViewModel>
  private let onAction: (Action) -> Void
  private var focus: FocusState<AppFocus?>.Binding

  init(_ focus: FocusState<AppFocus?>.Binding,
       configSelectionManager: SelectionManager<ConfigurationViewModel>,
       groupSelectionManager: SelectionManager<GroupViewModel>,
       contentSelectionManager: SelectionManager<ContentViewModel>,
       onAction: @escaping (Action) -> Void) {
    self.focus = focus
    self.configSelectionManager = configSelectionManager
    self.groupSelectionManager = groupSelectionManager
    self.contentSelectionManager = contentSelectionManager
    self.onAction = onAction
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Hide ui
//      ConfigurationContainerView(configSelectionManager: configSelectionManager,
//                                 onAction: onAction)

      if #available(macOS 14.0, *) {
          SettingsLink {
              Text("Enter ChatGPT API key")
          }
          .padding(.top, 6)
          .padding(.horizontal)
          .padding(.bottom, 6)
      }
      else {
          Button(action: {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
          }, label: {
            Text("Enter ChatGPT API key")
          })
          .buttonStyle(.zen(.init(calm: true, color: .systemGreen, grayscaleEffect: .constant(true))))
        .padding(.top, 6)
        .padding(.bottom, 6)
      }
      
      Divider()
      
      GroupContainerView(namespace,
                         contentSelectionManager: contentSelectionManager,
                         groupSelectionManager: groupSelectionManager,
                         onAction: onAction,
                         focus: focus)

      Divider()
      
      HStack {
        Button(action: {
          if let url = URL(string: "https://marciai.app/feedback") {
              openURL(url)
          }
        }, label: {
          Text("Feedback")
        })
        .padding(.vertical, 4)
        .padding(.horizontal)
        
        Button(action: {
          if let url = URL(string: "https://marciai.app/roadmap") {
              openURL(url)
          }
        }, label: {
          Text("Roadmap")
        })
      }
      
      // Hide ui
//      UserModeContainerView(onAction: onAction)
    }
  }
}

struct SidebarView_Previews: PreviewProvider {
  @FocusState static var focus: AppFocus?
  static var previews: some View {
    VStack(alignment: .leading) {
      SidebarView(
        $focus,
        configSelectionManager: .init(),
        groupSelectionManager: .init(),
        contentSelectionManager: .init()
      ) { _ in }
    }
      .designTime()
  }
}
