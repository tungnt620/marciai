import SwiftUI

@MainActor
final class GroupStore: ObservableObject {
  private static var appStorage: AppStorageStore = .init()
  @Published var groups = [WorkflowGroup]()

  init(_ groups: [WorkflowGroup] = []) {
    _groups = .init(initialValue: groups)
  }

  func group(withId id: String) -> WorkflowGroup? {
    groups.first { $0.id == id }
  }

  func add(_ group: WorkflowGroup) {
    var modifiedGroups = self.groups
    modifiedGroups.append(group)
    groups = modifiedGroups
  }

  func move(source: IndexSet, destination: Int) {
    groups.move(fromOffsets: source, toOffset: destination)
  }

  func updateGroups(_ groups: [WorkflowGroup]) async {
    let oldGroups = self.groups
    var newGroups = self.groups
    for group in groups {
      guard let index = oldGroups.firstIndex(where: { $0.id == group.id }) else { return }
      newGroups[index] = group
    }
    self.groups = newGroups
  }

  @MainActor @discardableResult
  func receive(_ newWorkflows: [Workflow]) -> [WorkflowGroup] {
    let newGroups = updateOrAddWorkflows(with: newWorkflows)
    groups = newGroups
    return newGroups
  }

  func remove(_ groups: [WorkflowGroup]) {
    for group in groups {
      remove(group)
    }
  }

  func removeGroups(with ids: [WorkflowGroup.ID]) {
    groups.removeAll(where: { ids.contains($0.id) })
  }

  func remove(_ group: WorkflowGroup) {
    groups.removeAll(where: { $0.id == group.id })
  }

  func workflow(withId id: Workflow.ID) -> Workflow? {
    groups
      .flatMap(\.workflows)
      .first(where: { $0.id == id })
  }

  func command(withId id: Command.ID, workflowId: Workflow.ID) -> Command? {
    workflow(withId: workflowId)?
      .commands
      .first(where: { $0.id == id })
  }

  func remove(_ workflow: Workflow) {
    guard let groupIndex = groups.firstIndex(where: {
      let ids = $0.workflows.compactMap({ $0.id })
      return ids.contains(workflow.id)
    }) else {
      return
    }

    var modifiedGroups = groups
    modifiedGroups[groupIndex].workflows.removeAll(where: { $0.id == workflow.id })
    groups = modifiedGroups
  }

  // MARK: Private methods

  private func updateOrAddWorkflows(with newWorkflows: [Workflow]) -> [WorkflowGroup] {
    // Fix bug when trying to reorder group.
    var newGroups = groups
    for newWorkflow in newWorkflows {
      guard let group = newGroups.first(where: { group in
        let workflowIds = group.workflows.compactMap({ $0.id })
        return workflowIds.contains(newWorkflow.id)
      })
      else { continue }

      guard let groupIndex = newGroups.firstIndex(of: group) else { continue }

      guard let workflowIndex = group.workflows.firstIndex(where: { $0.id == newWorkflow.id })
      else {
        newGroups[groupIndex].workflows.append(newWorkflow)
        continue
      }

      let oldWorkflow = groups[groupIndex].workflows[workflowIndex]
      if oldWorkflow == newWorkflow {
        continue
      }

      newGroups[groupIndex].workflows[workflowIndex] = newWorkflow
    }
    return newGroups
  }
}
