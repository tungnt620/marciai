import Foundation

struct Configuration: Identifiable, Codable, Hashable, Sendable {
  let id: String
  var name: String
  var groups: [WorkflowGroup]

  init(id: String = UUID().uuidString, name: String, groups: [WorkflowGroup]) {
    self.id = id
    self.name = name
    self.groups = groups
  }

  static func empty() -> Configuration {
    Configuration(id: UUID().uuidString, name: "Untitled configuration", groups: [])
  }
}
