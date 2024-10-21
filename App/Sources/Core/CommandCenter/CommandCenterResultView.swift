import SwiftUI

struct CommandCenterResultView: View {
  @AppStorage("Setting.chatGptApiKey") var chatGptApiKey: String = ""

  @EnvironmentObject var statePublisher: DetailStatePublisher
  
  @EnvironmentObject private var commandPublisher: CommandsPublisher
  @EnvironmentObject private var infoPublisher: InfoPublisher
  @EnvironmentObject private var triggerPublisher: TriggerPublisher
  
  private let applicationTriggerSelectionManager: SelectionManager<DetailViewModel.ApplicationTrigger>
  private let commandSelectionManager: SelectionManager<CommandViewModel>
  private let keyboardShortcutSelectionManager: SelectionManager<KeyShortcut>
  private var focus: FocusState<AppFocus?>.Binding
  private var onAction: (DetailView.Action) -> Void

  init(_ focus: FocusState<AppFocus?>.Binding,
       applicationTriggerSelectionManager: SelectionManager<DetailViewModel.ApplicationTrigger>,
       commandSelectionManager: SelectionManager<CommandViewModel>,
       keyboardShortcutSelectionManager: SelectionManager<KeyShortcut>,
       triggerPublisher: TriggerPublisher,
       infoPublisher: InfoPublisher,
       commandPublisher: CommandsPublisher,
       onAction: @escaping (DetailView.Action) -> Void
  ) {
    self.focus = focus
    self.onAction = onAction
    self.commandSelectionManager = commandSelectionManager
    self.applicationTriggerSelectionManager = applicationTriggerSelectionManager
    self.keyboardShortcutSelectionManager = keyboardShortcutSelectionManager
  }

  @ViewBuilder
  var body: some View {
    let chatGptCommand = getFirstChatGptCommand()
  
    if let chatGptCommand = chatGptCommand {
          switch chatGptCommand.kind {
          case .chatGpt(let chatGptModel):
            // Fetch the selected text from the pasteboard
            let selectedText = fetchSelectedTextFromPasteboard()
            let canCall = canCallChatGptApi(chatGptApiKey: chatGptApiKey)
            if canCall {
              ChatGptResultView(input: chatGptModel.promt, selectedText: selectedText).id(chatGptModel.id)
            }
          default:
            Text("We don't have a result for this command")
          }
        } else {
          Text("We don't have a result for this command")
        }
  }
  
  private func getFirstChatGptCommand() -> CommandViewModel? {
    return commandPublisher.data.commands.first {
      print($0)
      switch $0.kind {
      case .chatGpt(_):
        return true
      default:
        return false
      }
    }
    
  }
}

struct CommandCenterResultView_Previews: PreviewProvider {
  @FocusState static var focus: AppFocus?
  static var previews: some View {
    CommandCenterResultView($focus, applicationTriggerSelectionManager: .init(),
               commandSelectionManager: .init(),
               keyboardShortcutSelectionManager: .init(),
               triggerPublisher: DesignTime.triggerPublisher,
               infoPublisher: DesignTime.infoPublisher,
                            commandPublisher: DesignTime.commandsPublisher) { _ in }
      .designTime()
      .frame(height: 650)
  }
}
