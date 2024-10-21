import Bonzai
import SwiftUI

struct CommandCenterGroupContainerView: View {
  @EnvironmentObject private var publisher: GroupsPublisher
  private let contentSelectionManager: SelectionManager<ContentViewModel>
  private let groupSelectionManager: SelectionManager<GroupViewModel>
  private let onAction: (SidebarView.Action) -> Void
  private var focus: FocusState<AppFocus?>.Binding

  init(
       contentSelectionManager: SelectionManager<ContentViewModel>,
       groupSelectionManager: SelectionManager<GroupViewModel>,
       onAction: @escaping (SidebarView.Action) -> Void,
       focus: FocusState<AppFocus?>.Binding) {
    self.contentSelectionManager = contentSelectionManager
    self.groupSelectionManager = groupSelectionManager
    self.onAction = onAction
    self.focus = focus
  }

  var body: some View {
    CommandCenterGroupsListView(focus,
                   selectionManager: groupSelectionManager,
                   contentSelectionManager: contentSelectionManager) { action in
      switch action {
      case .selectGroups(let ids):
        onAction(.selectGroups(ids))
      }
    }
  }
}
