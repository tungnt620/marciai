import SwiftUI
import ModelKit

public class UserSelection: ObservableObject {
  @Published public var group: ModelKit.Group?
  @Published public var workflow: Workflow?
  @Published public var searchQuery: String = ""

  public init(group: ModelKit.Group? = nil, workflow: ModelKit.Workflow? = nil) {
    self.group = group
    self.workflow = workflow
  }
}
