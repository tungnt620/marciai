import SwiftUI
import ModelKit

public struct WorkflowView: View {
  static let idealWidth: CGFloat = 500

  let workflow: Workflow
  let group: ModelKit.Group
  let applicationProvider: ApplicationProvider
  let commandController: CommandController
  let keyboardShortcutController: KeyboardShortcutController
  let openPanelController: OpenPanelController
  let workflowController: WorkflowController
  @State private var newCommandVisible: Bool = false

  public var body: some View {
    GeometryReader { g in
    ScrollView {
      VStack {
        VStack {
          name(workflow, in: group)
        }
        .padding(.horizontal)
        .padding(.top)
        .background(Color(.textBackgroundColor))

        Divider()

        VStack(alignment: .leading, spacing: 0) {
          if workflow.keyboardShortcuts.isEmpty {
            VStack {
              AddButton(text: "Add Keyboard Shortcut",
                        alignment: .center,
                        action: {
                          keyboardShortcutController.perform(.createKeyboardShortcut(
                                                              ModelKit.KeyboardShortcut.empty(),
                                                              index: workflow.keyboardShortcuts.count,
                                                              in: workflow))
                        }).padding(.vertical, 8)
            }
          } else {
            HeaderView(title: "Keyboard shortcuts:")
              .padding([.leading, .top])
            keyboardShortcuts(for: workflow)
              .padding(.top)
          }
        }.padding(.horizontal, 8)
      }
      .background(Color(.textBackgroundColor))

      VStack(alignment: .leading, spacing: 0) {
        HeaderView(title: "Commads:")
          .padding([.leading, .top])
        if workflow.commands.isEmpty {
          VStack {
            AddButton(text: "Add Command",
                      alignment: .center,
                      action: { newCommandVisible = true }).padding(.vertical, 8)
              .sheet(isPresented: $newCommandVisible, content: {
                EditCommandView(
                  applicationProvider: applicationProvider,
                  openPanelController: openPanelController,
                  saveAction: { newCommand in
                    commandController.action(.createCommand(newCommand, in: workflow))()
                    newCommandVisible = false
                  },
                  cancelAction: {
                    newCommandVisible = false
                  },
                  selection: Command.application(.init(application: Application.empty())),
                  command: Command.application(.init(application: Application.empty())))
              })
          }
        } else {
          commands(for: workflow).padding(.top)
        }
      }
      .frame(alignment: .leading)
      .padding(.horizontal, 8)
    }
    .background(LinearGradient(
                  gradient: Gradient(
                    stops: [
                      .init(color: Color(.windowBackgroundColor).opacity(0.25), location: 0.8),
                      .init(color: Color(.gridColor).opacity(0.75), location: 1.0),
                    ]),
                  startPoint: .top,
                  endPoint: .bottom))
    }
  }
}

private extension WorkflowView {
  func name(_ workflow: Workflow, in group: ModelKit.Group) -> some View {
    TextField("", text: Binding<String>(get: { workflow.name }, set: { name in
      var workflow = workflow
      workflow.name = name
      workflowController.action(.updateWorkflow(workflow, in: group))()
    }))
      .font(.largeTitle)
      .foregroundColor(.primary)
      .textFieldStyle(PlainTextFieldStyle())
  }

  func keyboardShortcuts(for workflow: Workflow) -> some View {
    KeyboardShortcutListView(keyboardShortcutController: keyboardShortcutController,
                             keyboardShortcuts: workflow.keyboardShortcuts,
                             workflow: workflow)
      .frame(alignment: .top)
      .padding(.bottom, 24)
      .shadow(color: Color(.separatorColor).opacity(0.05), radius: 5, x: 0, y: 2.5)
  }

  func commands(for workflow: Workflow) -> some View {
    CommandListView(applicationProvider: applicationProvider,
                    commandController: commandController,
                    openPanelController: openPanelController,
                    workflow: workflow)
      .frame(alignment: .top)
      .padding(.bottom, 24)
      .shadow(color: Color(.separatorColor).opacity(0.05), radius: 5, x: 0, y: 2.5)
  }
}

// MARK: - Previews

struct WorkflowView_Previews: PreviewProvider, TestPreviewProvider {
  static var previews: some View {
    testPreview.previewAllColorSchemes()
  }

  static var testPreview: some View {
    DesignTimeFactory().workflowDetail(
      ModelFactory().workflowDetail(),
      group: ModelFactory().groupList().first!)
      .environmentObject(UserSelection())
      .frame(height: 668)
  }
}
