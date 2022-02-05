import SwiftUI

struct WorkflowRowView: View, Equatable {
  let applicationStore: ApplicationStore
  @Binding var workflow: Workflow

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 0) {
        Text(workflow.name)
        HStack {
          Text("\(workflow.commands.count) command") + Text(workflow.commands.count > 1 ? "s" : "")
          if let trigger = workflow.trigger {
            Divider().frame(height: 10)
            triggers(trigger)
          }
        }
        .font(Font.caption)
        .foregroundColor(Color(.secondaryLabelColor))
      }
      Spacer()
      icons(workflow.commands)
    }
    .padding(4)
    .opacity(workflow.isEnabled ? 1.0 : 0.6)
  }

  @ViewBuilder
  func triggers(_ trigger: Workflow.Trigger) -> some View {
    switch trigger {
    case .keyboardShortcuts(let shortcuts):
      ForEach(shortcuts, content: KeyboardShortcutView.init)
    case .application(let triggers):
      ZStack {
        ForEach(triggers) { contextView($0.contexts) }
      }
    }
  }

  @ViewBuilder
  func contextView(_ contexts: Set<ApplicationTrigger.Context>) -> some View {
    HStack(spacing: 1) {
      if contexts.contains(.closed) {
        Circle().fill(Color(.systemRed))
          .frame(width: 6)
      }
      if contexts.contains(.launched) {
        Circle().fill(Color(.systemYellow))
          .frame(width: 6)
      }
      if contexts.contains(.frontMost) {
        Circle().fill(Color(.systemGreen))
          .frame(width: 6)
      }
    }
    .frame(height: 10)
    .padding(.horizontal, 1)
    .overlay(
      RoundedRectangle(cornerRadius: 4)
        .stroke(Color(NSColor.systemGray.withSystemEffect(.disabled)), lineWidth: 1)
    )
    .opacity(0.8)
  }

  func icons(_ commands: [Command]) -> some View {
    ZStack {
      ForEach(commands) { command in
        switch command {
        case .application(let command):
          IconView(path: command.application.path)
            .frame(width: 32, height: 32)
        case .script(let command):
          switch command {
          case .appleScript:
            IconView(path: "/System/Applications/Utilities/Script Editor.app")
              .frame(width: 32, height: 32)
          case .shell:
            IconView(path: "/System/Applications/Utilities/Terminal.app")
              .frame(width: 32, height: 32)
          }
        case .keyboard(let command):
          RegularKeyIcon(letter: command.keyboardShortcut.key)
            .frame(width: 24, height: 24)
            .offset(x: -4, y: 0)
        case .open(let command):
          if let application = command.application {
            IconView(path: application.path)
              .frame(width: 32, height: 32)
          } else if command.isUrl {
            IconView(path: "/Applications/Safari.app")
              .frame(width: 32, height: 32)
          } else {
            IconView(path: command.path)
              .frame(width: 32, height: 32)
          }
          Spacer()
        case .builtIn:
          Spacer()
        case .type:
          Spacer()
        }
      }
    }
  }

  static func == (lhs: WorkflowRowView, rhs: WorkflowRowView) -> Bool {
    lhs.workflow.id == rhs.workflow.id &&
    lhs.workflow.isEnabled == rhs.workflow.isEnabled &&
    lhs.workflow.name == rhs.workflow.name &&
    lhs.workflow.trigger == rhs.workflow.trigger &&
    lhs.workflow.commands == rhs.workflow.commands
  }
}

struct WorkflowRowView_Previews: PreviewProvider {
    static var previews: some View {
      WorkflowRowView(
        applicationStore: ApplicationStore(),
        workflow: .constant(Workflow.designTime(.none)))
    }
}
