import Carbon
import SwiftUI


struct CommandCenterGroupsListView: View {
  enum Action {
    case selectGroups(Set<GroupViewModel.ID>)
  }

  enum Confirm {
    case single(id: GroupViewModel.ID)
    case multiple(ids: [GroupViewModel.ID])

    func contains(_ id: GroupViewModel.ID) -> Bool {
      switch self {
      case .single(let groupId):
        return groupId == id
      case .multiple(let ids):
        return ids.contains(id) && ids.first == id
      }
    }
  }

  @FocusState var focus: LocalFocus<GroupViewModel>?
  @EnvironmentObject private var publisher: GroupsPublisher
  private let contentSelectionManager: SelectionManager<ContentViewModel>
  private let debounce: DebounceController<GroupDebounce>
  private let onAction: (CommandCenterGroupsListView.Action) -> Void
  private let selectionManager: SelectionManager<GroupViewModel>
  private var appFocus: FocusState<AppFocus?>.Binding

  init(_ appFocus: FocusState<AppFocus?>.Binding,
       selectionManager: SelectionManager<GroupViewModel>,
       contentSelectionManager: SelectionManager<ContentViewModel>,
       onAction: @escaping (CommandCenterGroupsListView.Action) -> Void) {
    self.appFocus = appFocus
    self.selectionManager = selectionManager
    self.contentSelectionManager = contentSelectionManager
    self.onAction = onAction
    self.debounce = .init(.init(groups: selectionManager.selections),
                          milliseconds: 150,
                          onUpdate: { snapshot in
      onAction(.selectGroups(snapshot.groups))
    })
  }

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
          LazyVStack(spacing: 0) {
            ForEach(publisher.data.lazy, id: \.id) { group in
              CommandCenterGroupItemView(group, selectionManager: selectionManager,
                            onAction: onAction)
              .contentShape(Rectangle())
              .modifier(LegacyOnTapFix(onTap: {
                focus = .element(group.id)
                onTap(group)
              }))
              .focusable($focus, as: .element(group.id)) {
                if let keyCode = LocalEventMonitor.shared.event?.keyCode, keyCode == kVK_Tab,
                   let lastSelection = selectionManager.lastSelection,
                   let match = publisher.data.first(where: { $0.id == lastSelection }) {
                  focus = .element(match.id)
                } else {
                  onTap(group)
                  proxy.scrollTo(group.id)
                }
              }
            }
          }
          .onAppear {
            guard let initialSelection = selectionManager.initialSelection else { return }
            focus = .element(initialSelection)
            proxy.scrollTo(initialSelection)
          }
          .focused(appFocus, equals: .groups)
          .padding(.horizontal, 8)
        }
    }
  }

  private func onTap(_ element: GroupViewModel) {
    selectionManager.handleOnTap(publisher.data, element: element)
    debounce.process(.init(groups: selectionManager.selections))
  }
}

struct CommandCenterGroupsListView_Previews: PreviewProvider {
  @FocusState static var focus: AppFocus?
  static var previews: some View {
    CommandCenterGroupsListView($focus,
                   selectionManager: .init(),
                   contentSelectionManager: .init(),
                   onAction: { _ in })
    .designTime()
  }
}
