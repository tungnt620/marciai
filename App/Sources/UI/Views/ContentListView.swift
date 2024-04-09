import Carbon
import SwiftUI

struct ContentDebounce: DebounceSnapshot {
  let workflows: Set<ContentViewModel.ID>
}

@MainActor
struct ContentListView: View {
  enum Match {
    case unmatched
    case typeMatch(Kind)
    case match

    enum Kind: String, CaseIterable {
      case application = "app"
      case builtIn = "builtIn"
      case open = "open"
      case keyboard = "keyboard"
      case script = "script"
      case plain = "plain"
      case snippet = "snippet"
      case shortcut = "shortcut"
      case text = "text"
      case systemCommand = "system"
      case menuBar = "menubar"
      case mouse = "mouse"
      case uiElement = "ui"
      case windowManagement = "window"
    }
  }

  enum Action: Hashable {
    case duplicate(workflowIds: Set<ContentViewModel.ID>)
    case refresh(_ groupIds: Set<WorkflowGroup.ID>)
    case moveWorkflowsToGroup(_ groupId: WorkflowGroup.ID, workflows: Set<ContentViewModel.ID>)
    case moveCommandsToWorkflow(_ workflowId: ContentViewModel.ID, fromWorkflowId: ContentViewModel.ID, commands: Set<CommandViewModel.ID>)
    case selectWorkflow(workflowIds: Set<ContentViewModel.ID>)
    case removeWorkflows(Set<ContentViewModel.ID>)
    case reorderWorkflows(source: IndexSet, destination: Int)
    case addWorkflow(workflowId: Workflow.ID)
  }

  @FocusState var focus: LocalFocus<ContentViewModel>?
  @EnvironmentObject private var groupsPublisher: GroupsPublisher
  @EnvironmentObject private var publisher: ContentPublisher
  @Namespace private var namespace
  @State private var searchTerm: String = ""

  private let appFocus: FocusState<AppFocus?>.Binding
  private let contentSelectionManager: SelectionManager<ContentViewModel>
  private let groupId: String
  private let debounce: DebounceController<ContentDebounce>
  private let onAction: (Action) -> Void

  init(_ appFocus: FocusState<AppFocus?>.Binding, groupId: String,
       contentSelectionManager: SelectionManager<ContentViewModel>,
       onAction: @escaping (Action) -> Void) {
    self.appFocus = appFocus
    self.contentSelectionManager = contentSelectionManager
    self.groupId = groupId
    self.onAction = onAction
    let initialDebounce = ContentDebounce(workflows: contentSelectionManager.selections)
    self.debounce = .init(initialDebounce, milliseconds: 150, onUpdate: { snapshot in
      onAction(.selectWorkflow(workflowIds: snapshot.workflows))
    })
  }

  private func search(_ workflow: ContentViewModel) -> Bool {
    guard !searchTerm.isEmpty else { return true }

    var freetext = searchTerm.lowercased()
    let searchTerms = freetext.split(separator: " ")
    var match: Match = .unmatched

    for searchTerm in searchTerms {
      switch workflow.trigger {
      case .application(let app):
        match = app.lowercased().contains(searchTerm) ? .typeMatch(.application) : .unmatched
      case .keyboard(let string):
        if searchTerm.contains("function") {
          match = string.lowercased().contains(ModifierKey.function.pretty) ? .typeMatch(.keyboard) : .unmatched
          freetext = freetext.replacingFirstOccurrence(of: "function ", with: "")
        } else if searchTerm.contains("function") {
          match = string.lowercased().contains(ModifierKey.function.pretty) ? .typeMatch(.keyboard) : .unmatched
          freetext = freetext.replacingFirstOccurrence(of: "fn ", with: "")
        } else if searchTerm.contains("command") {
          match = string.lowercased().contains(ModifierKey.command.pretty) ? .typeMatch(.keyboard) : .unmatched
          freetext = freetext.replacingFirstOccurrence(of: "command ", with: "")
        } else if searchTerm.contains("shift") {
          match = string.lowercased().contains(ModifierKey.shift.pretty) ? .typeMatch(.keyboard) : .unmatched
          freetext = freetext.replacingFirstOccurrence(of: "shift ", with: "")
        } else if searchTerm.contains("option") {
          match = string.lowercased().contains(ModifierKey.option.pretty) ? .typeMatch(.keyboard) : .unmatched
          freetext = freetext.replacingFirstOccurrence(of: "option ", with: "")
        } else if searchTerm.contains("control") {
          match = string.lowercased().contains(ModifierKey.control.pretty) ? .typeMatch(.keyboard) : .unmatched
          freetext = freetext.replacingFirstOccurrence(of: "control ", with: "")
        } else {
          match = string.lowercased().contains(searchTerm) ? .typeMatch(.keyboard) : .unmatched
        }
      case .snippet(let snippet):
        if snippet.lowercased().contains(searchTerm) {
          match = .typeMatch(.snippet)
        } else if searchTerm.contains("snippet ") {
          match = .typeMatch(.snippet)
        }
      default: continue
      }

      for image in workflow.images {
        switch image.kind {
        case .command(let kind):
          if searchTerm.contains(kind.match.rawValue) {
            match = .typeMatch(kind.match)
            freetext = freetext.replacingFirstOccurrence(of: kind.match.rawValue + " ", with: "")
          }
        case .icon(let icon):
          if searchTerm.contains("app") && icon.path.contains("app") {
            match = .typeMatch(.application)
            break
          }
        }
      }

      if workflow.name.lowercased().contains(freetext) {
        return true
      }
    }

    return switch match {
    case .unmatched: false
    case .typeMatch: searchTerms.count == 1 ? true : false
    case .match: true
    }
  }

  @ViewBuilder
  var body: some View {
    ScrollViewReader { proxy in
      ContentHeaderView(namespace: namespace,
                        showAddButton: .readonly(!publisher.data.isEmpty),
                        onAction: onAction)

      ContentListFilterView(appFocus, onClear: {
        let match = contentSelectionManager.lastSelection ?? contentSelectionManager.selections.first ?? ""
        appFocus.wrappedValue = .workflows
        DispatchQueue.main.async {
          proxy.scrollTo(match)
        }
      }, onChange: { newValue in
        withAnimation(.smooth(duration: 0.2)) {
          searchTerm = newValue
        }
      })

      if groupsPublisher.data.isEmpty {
        Text("Add a group before adding a workflow.")
          .frame(maxWidth: .infinity)
          .padding()
          .multilineTextAlignment(.center)
          .foregroundColor(Color(.systemGray))
      }

      ScrollView {
        if publisher.data.isEmpty {
          ContentListEmptyView(namespace, onAction: onAction)
        } else {
          LazyVStack(spacing: 0) {
            let items = publisher.data.filter({ search($0) })
            ForEach(items.lazy, id: \.id) { element in
              ContentItemView(
                workflow: element,
                publisher: publisher,
                contentSelectionManager: contentSelectionManager,
                onAction: onAction
              )
              .contentShape(Rectangle())
              .dropDestination(ContentListDropItem.self, color: .accentColor, onDrop: { items, location in
                for item in items {
                  switch item {
                  case .workflow:
                    let ids = Array(contentSelectionManager.selections)
                    guard let (from, destination) = publisher.data.moveOffsets(for: element, with: ids) else { return false }

                    withAnimation(.spring(response: 0.3, dampingFraction: 0.65, blendDuration: 0.2)) {
                      publisher.data.move(fromOffsets: IndexSet(from), toOffset: destination)
                    }

                    onAction(.reorderWorkflows(source: from, destination: destination))
                  case .command(let command):
                    guard let fromId = contentSelectionManager.selections.first else {
                      return false
                    }

                    onAction(.moveCommandsToWorkflow(
                      element.id,
                      fromWorkflowId: fromId,
                      commands: [command.id]))
                  }
                }

                return true
              })
              .modifier(LegacyOnTapFix(onTap: {
                focus = .element(element.id)
                onTap(element)
              }))
              .contextMenu(menuItems: {
                contextualMenu(element.id)
              })
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
            .onCommand(#selector(NSResponder.insertTab(_:)), perform: {
              appFocus.wrappedValue = .detail(.name)
            })
            .onCommand(#selector(NSResponder.insertBacktab(_:)), perform: {
              if searchTerm.isEmpty {
                appFocus.wrappedValue = .groups
              } else {
                appFocus.wrappedValue = .search
              }
            })
            .onCommand(#selector(NSResponder.selectAll(_:)),
                       perform: {
              let newSelections = Set(publisher.data.map(\.id))
              contentSelectionManager.publish(newSelections)
              if let elementID = publisher.data.first?.id,
                 let lastSelection = contentSelectionManager.lastSelection {
                focus = .element(elementID)
                focus = .element(lastSelection)
              }
            })
            .onMoveCommand(perform: { direction in
              if let elementID = contentSelectionManager.handle(
                direction,
                publisher.data.filter({ search($0) }),
                proxy: proxy,
                vertical: true) {
                focus = .element(elementID)
              }
            })
            .onDeleteCommand {
              if contentSelectionManager.selections.count == publisher.data.count {
                withAnimation {
                  onAction(.removeWorkflows(contentSelectionManager.selections))
                }
              } else {
                onAction(.removeWorkflows(contentSelectionManager.selections))
                if let first = contentSelectionManager.selections.first {
                  let index = max(publisher.data.firstIndex(where: { $0.id == first }) ?? 0, 0)
                  let newId = publisher.data[index].id
                  focus = .element(newId)
                }
              }
            }

            Text("Results: \(items.count)")
              .font(.caption)
              .opacity(!searchTerm.isEmpty ? 1 : 0)
              .padding(.vertical, 8)
              .frame(height: searchTerm.isEmpty ? 0 : nil)

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
          .onChange(of: searchTerm, perform: { newValue in
            if !searchTerm.isEmpty {
              if let firstSelection = publisher.data.filter({ search($0) }).first {
                contentSelectionManager.publish([firstSelection.id])
              } else {
                contentSelectionManager.publish([])
              }

              debounce.process(.init(workflows: contentSelectionManager.selections))
            }
          })
          .padding(8)
          .toolbar {
            ToolbarItemGroup(placement: .navigation) {
              Button(action: {
                searchTerm = ""
                onAction(.addWorkflow(workflowId: UUID().uuidString))
              },
                     label: {
                Label(title: {
                  Text("Add workflow")
                }, icon: {
                  Image(systemName: "rectangle.stack.badge.plus")
                    .renderingMode(.template)
                    .foregroundColor(Color(.systemGray))
                })
              })
              .opacity(publisher.data.isEmpty ? 0 : 1)
              .help("Add workflow")
            }
          }
          .onReceive(NotificationCenter.default.publisher(for: .newWorkflow), perform: { _ in
            proxy.scrollTo("bottom")
          })
        }
      }
    }
  }

  private func onTap(_ element: ContentViewModel) {
    contentSelectionManager.handleOnTap(publisher.data, element: element)
    debounce.process(.init(workflows: contentSelectionManager.selections))
  }

  @ViewBuilder
  private func contextualMenu(_ selectedId: ContentViewModel.ID) -> some View {
    Button("Duplicate", action: {
      if contentSelectionManager.selections.contains(selectedId) {
        onAction(.duplicate(workflowIds: contentSelectionManager.selections))
      } else {
        onAction(.duplicate(workflowIds: [selectedId]))
        contentSelectionManager.publish([selectedId])
        contentSelectionManager.setLastSelection(selectedId)
      }

      if contentSelectionManager.selections.count == 1 {
        appFocus.wrappedValue = .detail(.name)
      }
    })
    Menu("Move to") {
      // Show only other groups than the current one.
      // TODO: This is a bottle-neck for performance
      //      .filter({ !groupSelectionManager.selections.contains($0.id) })) { group in
      ForEach(groupsPublisher.data, id: \.self) { group in
        Button(group.name) {
          onAction(.moveWorkflowsToGroup(group.id, workflows: contentSelectionManager.selections))
        }
      }
    }
    Button("Delete", action: {
      onAction(.removeWorkflows(contentSelectionManager.selections))
    })
  }
}

struct LegacyOnTapFix: ViewModifier {
  let onTap: () -> Void

  @ViewBuilder
  func body(content: Content) -> some View {
    if #available(macOS 14.0, *) {
      content
    } else {
      content
        .onTapGesture(perform: onTap)
    }
  }
}

struct ContentListView_Previews: PreviewProvider {
  @FocusState static var focus: AppFocus?
  static var previews: some View {
    ContentListView($focus, groupId: UUID().uuidString,
                    contentSelectionManager: .init()) { _ in }
      .designTime()
  }
}

fileprivate extension CommandViewModel.Kind {
  var match: ContentListView.Match.Kind {
    switch self {
    case .application: .application
    case .builtIn: .builtIn
    case .open: .open
    case .keyboard: .keyboard
    case .script: .script
    case .plain: .plain
    case .shortcut: .shortcut
    case .text: .text
    case .systemCommand: .systemCommand
    case .menuBar: .menuBar
    case .mouse: .mouse
    case .uiElement: .uiElement
    case .windowManagement: .windowManagement
    }
  }
}

fileprivate extension String {
  func replacingFirstOccurrence(of target: String, with replacement: String) -> String {
    guard let range = self.range(of: target) else {
      return self
    }

    return self.replacingCharacters(in: range, with: replacement)
  }
}
