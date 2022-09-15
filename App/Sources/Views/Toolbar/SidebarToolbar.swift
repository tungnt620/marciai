import SwiftUI

struct SidebarToolbar: ToolbarContent {
  enum Action {
    case addGroup
    case toggleSidebar
  }

  let configurationStore: ConfigurationStore
  let contentStore: ContentStore
  @FocusState var focus: Focus?
  var action: (Action) -> Void

  var body: some ToolbarContent {
    ToolbarItemGroup {
      Button(action: { action(.toggleSidebar) },
             label: {
        Label(title: {
          Text("Toggle Sidebar")
        }, icon: {
          Image(systemName: "sidebar.left")
            .renderingMode(.template)
            .foregroundColor(Color(.systemGray))
        })
      })

      Button(action: { action(.addGroup) },
             label: {
        Label(title: {
          Text("Add group")
        }, icon: {
          Image(systemName: "folder.badge.plus")
            .renderingMode(.template)
            .foregroundColor(Color(.systemGray))
        })
      })
    }
  }
}
