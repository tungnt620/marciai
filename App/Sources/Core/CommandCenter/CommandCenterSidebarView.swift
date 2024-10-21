import Bonzai
import SwiftUI

struct CommandCenterSidebarView: View {
  @Environment(\.openURL) var openURL
  @EnvironmentObject private var publisher: GroupsPublisher
  private let configSelectionManager: SelectionManager<ConfigurationViewModel>
  private let contentSelectionManager: SelectionManager<ContentViewModel>
  private let groupSelectionManager: SelectionManager<GroupViewModel>
  private let onAction: (SidebarView.Action) -> Void
  private var focus: FocusState<AppFocus?>.Binding

  init(_ focus: FocusState<AppFocus?>.Binding,
       configSelectionManager: SelectionManager<ConfigurationViewModel>,
       groupSelectionManager: SelectionManager<GroupViewModel>,
       contentSelectionManager: SelectionManager<ContentViewModel>,
       onAction: @escaping (SidebarView.Action) -> Void) {
    self.focus = focus
    self.configSelectionManager = configSelectionManager
    self.groupSelectionManager = groupSelectionManager
    self.contentSelectionManager = contentSelectionManager
    self.onAction = onAction
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      CommandCenterGroupContainerView(
                         contentSelectionManager: contentSelectionManager,
                         groupSelectionManager: groupSelectionManager,
                         onAction: onAction,
                         focus: focus)
    }
  }
}

struct CommandCenterSidebarView_Previews: PreviewProvider {
  @FocusState static var focus: AppFocus?
  static var previews: some View {
    VStack(alignment: .leading) {
      CommandCenterSidebarView(
        $focus,
        configSelectionManager: .init(),
        groupSelectionManager: .init(),
        contentSelectionManager: .init()
      ) { _ in }
    }
      .designTime()
  }
}
