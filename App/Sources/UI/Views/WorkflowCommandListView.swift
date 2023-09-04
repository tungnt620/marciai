import SwiftUI
import UniformTypeIdentifiers

struct WorkflowCommandListView: View {
  static let animation: Animation = .spring(response: 0.3, dampingFraction: 0.65, blendDuration: 0.2)

  @FocusState var isFocused: Bool

  @ObserveInjection var inject
  @Environment(\.openWindow) var openWindow
  var namespace: Namespace.ID
  @EnvironmentObject var applicationStore: ApplicationStore
  @ObservedObject private var detailPublisher: DetailPublisher
  @ObservedObject private var selectionManager: SelectionManager<CommandViewModel>
  @State private var dropOverlayIsVisible: Bool = false
  @State private var dropUrls = Set<URL>()
  private var focusPublisher = FocusPublisher<CommandViewModel>()
  private let scrollViewProxy: ScrollViewProxy?
  private let onAction: (SingleDetailView.Action) -> Void
  private let focus: FocusState<AppFocus?>.Binding

  init(_ focus: FocusState<AppFocus?>.Binding,
       namespace: Namespace.ID,
       publisher: DetailPublisher,
       selectionManager: SelectionManager<CommandViewModel>,
       scrollViewProxy: ScrollViewProxy? = nil,
       onAction: @escaping (SingleDetailView.Action) -> Void) {
    self.focus = focus
    self.namespace = namespace
    _detailPublisher = .init(initialValue: publisher)
    self.selectionManager = selectionManager
    self.scrollViewProxy = scrollViewProxy
    self.onAction = onAction
  }

  @ViewBuilder
  var body: some View {
    if detailPublisher.data.commands.isEmpty {
      WorkflowCommandEmptyListView(namespace: namespace,
                                   detailPublisher: detailPublisher, onAction: onAction)
      .matchedGeometryEffect(id: "command-list", in: namespace)
    } else {
      ScrollView {
        LazyVStack(spacing: 0) {
          ForEach($detailPublisher.data.commands, id: \.id) { element in
            let command = element
            CommandView(command,
                        detailPublisher: detailPublisher,
                        focusPublisher: focusPublisher,
                        selectionManager: selectionManager,
                        workflowId: detailPublisher.data.id,
                        onCommandAction: onAction, onAction: { action in
              onAction(.commandView(workflowId: detailPublisher.data.id, action: action))
            })
            .contextMenu(menuItems: {
              WorkflowCommandListContextMenuView(
                command.wrappedValue,
                detailPublisher: detailPublisher,
                selectionManager: selectionManager,
                onAction: onAction
              )
            })
            .onTapGesture {
              selectionManager.handleOnTap(detailPublisher.data.commands, element: element.wrappedValue)
              focusPublisher.publish(element.id)
            }
          }
          .focused($isFocused)
          .onChange(of: isFocused, perform: { newValue in
            guard newValue else { return }

            guard let lastSelection = selectionManager.lastSelection else { return }

            withAnimation {
              scrollViewProxy?.scrollTo(lastSelection)
            }
          })
          .padding(.vertical, 5)
          .onCommand(#selector(NSResponder.insertBacktab(_:)), perform: {
            switch detailPublisher.data.trigger {
            case .applications:
              focus.wrappedValue = .detail(.applicationTriggers)
            case .keyboardShortcuts:
              focus.wrappedValue = .detail(.keyboardShortcuts)
            case .none:
              focus.wrappedValue = .detail(.name)
            }
          })
          .onCommand(#selector(NSResponder.insertTab(_:)), perform: {
            focus.wrappedValue = .groups
          })
          .onCommand(#selector(NSResponder.selectAll(_:)), perform: {
            selectionManager.selections = Set(detailPublisher.data.commands.map(\.id))
          })
          .onMoveCommand(perform: { direction in
            if let elementID = selectionManager.handle(direction, detailPublisher.data.commands,
                                                       proxy: scrollViewProxy) {
              focusPublisher.publish(elementID)
            }
          })
          .onDeleteCommand {
            if selectionManager.selections.count == detailPublisher.data.commands.count {
              withAnimation {
                onAction(.removeCommands(workflowId: detailPublisher.data.id, commandIds: selectionManager.selections))
              }
            } else {
              onAction(.removeCommands(workflowId: detailPublisher.data.id, commandIds: selectionManager.selections))
            }
          }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .focused(focus, equals: .detail(.commands))
        .matchedGeometryEffect(id: "command-list", in: namespace)
      }
    }
  }
}

struct WorkflowCommandListView_Previews: PreviewProvider {
  @Namespace static var namespace
  @FocusState static var focus: AppFocus?
  static var previews: some View {
    WorkflowCommandListView($focus,
                            namespace: namespace,
                            publisher: DetailPublisher(DesignTime.detail),
                            selectionManager: .init()) { _ in }
      .frame(height: 900)
  }
}
