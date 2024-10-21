import Bonzai
import SwiftUI

struct CommandCenterGroupItemView: View {
  private let group: GroupViewModel
  private let onAction: (CommandCenterGroupsListView.Action) -> Void
  private let selectionManager: SelectionManager<GroupViewModel>

  init(_ group: GroupViewModel,
       selectionManager: SelectionManager<GroupViewModel>,
       onAction: @escaping (CommandCenterGroupsListView.Action) -> Void) {
    self.group = group
    self.selectionManager = selectionManager
    self.onAction = onAction
  }

  var body: some View {
    CommandCenterGroupItemInternalView(
      group,
      selectionManager: selectionManager,
      onAction: onAction
    )
  }
}

private struct CommandCenterGroupItemInternalView: View {
  @State private var isTargeted: Bool = false
  private let selectionManager: SelectionManager<GroupViewModel>
  private let group: GroupViewModel
  private let onAction: (CommandCenterGroupsListView.Action) -> Void

  init(_ group: GroupViewModel,
       selectionManager: SelectionManager<GroupViewModel>,
       onAction: @escaping (CommandCenterGroupsListView.Action) -> Void) {
    self.selectionManager = selectionManager
    self.group = group
    self.onAction = onAction
  }

  var body: some View {
    HStack(spacing: 8) {
      GroupIconView(color: group.color, icon: group.icon, symbol: group.symbol)
        .frame(width: 24)
      GroupTextView(group)
    }
    .padding(.vertical, 4)
    .padding(.horizontal, 8)
    .contentShape(Rectangle())
    .background(ItemBackgroundView(group.id, selectionManager: selectionManager))
    .draggable(group)
  }
}

private struct GroupTextView: View {
  private let group: GroupViewModel

  init(_ group: GroupViewModel) {
    self.group = group
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(group.name)
        .allowsTightening(true)
        .minimumScaleFactor(0.8)
        .font(group.userModes.isEmpty ? .body : .caption)
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}
