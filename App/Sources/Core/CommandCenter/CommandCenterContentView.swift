import Carbon
import SwiftUI


@MainActor
struct CommandCenterContentView: View {
  @FocusState var focus: LocalFocus<ContentViewModel>?
  @EnvironmentObject private var groupsPublisher: GroupsPublisher
  @EnvironmentObject private var publisher: ContentPublisher
  @Namespace private var namespace
  @EnvironmentObject private var groupStore: GroupStore

  private let appFocus: FocusState<AppFocus?>.Binding
  private let contentSelectionManager: SelectionManager<ContentViewModel>
  private let groupId: String
  private let debounce: DebounceController<ContentDebounce>
  private let onAction: (ContentView.Action) -> Void

  init(_ appFocus: FocusState<AppFocus?>.Binding, groupId: String,
       contentSelectionManager: SelectionManager<ContentViewModel>,
       onAction: @escaping (ContentView.Action) -> Void) {
    self.appFocus = appFocus
    self.contentSelectionManager = contentSelectionManager
    self.groupId = groupId
    self.onAction = onAction
    let initialDebounce = ContentDebounce(workflows: contentSelectionManager.selections)
    self.debounce = .init(initialDebounce, milliseconds: 150, onUpdate: { snapshot in
      onAction(.selectWorkflow(workflowIds: snapshot.workflows))
    })
  }

  @ViewBuilder
  var body: some View {
    ScrollViewReader { proxy in
      
      ScrollView {
          LazyVStack(spacing: 0) {
            let items = publisher.data.filter {
              $0.isEnabled
            }
            
            ForEach(items.lazy, id: \.id) { element in
              ContentItemView(
                workflow: element,
                publisher: publisher,
                contentSelectionManager: contentSelectionManager,
                onAction: onAction
              )
              .contentShape(Rectangle())
              .modifier(LegacyOnTapFix(onTap: {
                focus = .element(element.id)
                onTap(element)
              }))
              .focusable($focus, as: .element(element.id)) {
                if let keyCode = LocalEventMonitor.shared.event?.keyCode, keyCode == kVK_Tab,
                   let lastSelection = contentSelectionManager.lastSelection,
                   let match = publisher.data.first(where: { $0.id == lastSelection }) {
                  focus = .element(match.id)
                } else {
                  onTap(element)
                  proxy.scrollTo(element.id)
                }
              }
            }

            Color(.clear)
              .id("bottom")
              .padding(.bottom, 24)

          }
          .onAppear {
            guard let initialSelection = contentSelectionManager.initialSelection else { return }
            focus = .element(initialSelection)
            
            proxy.scrollTo(initialSelection)
          }
          .focused(appFocus, equals: .workflows)
          .padding(8)
        }
      }
  }

  private func onTap(_ element: ContentViewModel) {
    contentSelectionManager.handleOnTap(publisher.data, element: element)
    debounce.process(.init(workflows: contentSelectionManager.selections))
  }
}

struct CommandCenterContentView_Previews: PreviewProvider {
  @FocusState static var focus: AppFocus?
  static var previews: some View {
    CommandCenterContentView($focus, groupId: UUID().uuidString,
                    contentSelectionManager: .init()) { _ in }
      .designTime()
  }
}

