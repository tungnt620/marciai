import SwiftUI

struct WorkflowGroupListView: View {
  enum Action {
    case edit(WorkflowGroup)
    case delete(WorkflowGroup)
  }

  @ObservedObject var appStore: ApplicationStore
  @ObservedObject var groupStore: GroupStore
  @Binding var selection: Set<String>

  let action: (Action) -> Void

  var body: some View {
    VStack(alignment: .leading) {
      Label("Groups", image: "")
        .labelStyle(HeaderLabelStyle())
        .padding(.leading)
      List(groupStore.groups, selection: $selection) { group in
        WorkflowGroupView(applicationStore: appStore,
                          group: Binding<WorkflowGroup>(get: { group }, set: { _ in }))
          .contextMenu { contextMenuView(group) }
          .id(group.id)
          .padding(.leading, 8)
      }
      .listStyle(SidebarListStyle())
      .onCopyCommand(perform: {
        groupStore.groups
          .filter { selection.contains($0.id) }
          .compactMap {
            guard let string = try? $0.asString() else { return nil }
            return NSItemProvider(object: string as NSString)
          }
      })
      .onPasteCommand(of: [.text], perform: { items in
        let decoder = JSONDecoder()
        for item in items {
          item.loadObject(ofClass: NSString.self) { reading, error in
            guard let output = reading as? String,
                  let data = output.data(using: .utf8),
                  let group = try? decoder.decode(WorkflowGroup.self, from: data) else { return }
            DispatchQueue.main.async {
              self.groupStore.add(group.copy())
            }
          }
        }
      })
      .onDeleteCommand(perform: {
        let selectedGroups = groupStore.groups.filter({ selection.contains($0.id) })
        groupStore.remove(selectedGroups)
      })
    }
  }

  func contextMenuView(_ group: WorkflowGroup) -> some View {
    VStack {
      Button("Info", action: { action(.edit(group)) })
        .keyboardShortcut(.init("I"))
      Divider()
      Button("Delete", action: { action(.delete(group)) })
        .keyboardShortcut(.init(.delete, modifiers: []))
    }
  }
}

struct WorkflowGroupListView_Previews: PreviewProvider {
  static let store = Saloon()
  static var previews: some View {
    WorkflowGroupListView(appStore: ApplicationStore(),
                          groupStore: store.groupStore,
                          selection: .constant([]),
                          action: { _ in })
  }
}
