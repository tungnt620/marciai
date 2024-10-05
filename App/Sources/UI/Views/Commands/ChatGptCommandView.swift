import Bonzai
import Inject
import SwiftUI

struct ChatGptCommandView: View {
  @ObserveInjection var inject
  enum Action {
    case updateName(newName: String)
    case updatePromt(newPromt: String)
    case commandAction(CommandContainerAction)
  }
  private let metaData: CommandViewModel.MetaData
  private let model: CommandViewModel.Kind.ChatGptModel
  private let onAction: (Action) -> Void
  private let iconSize: CGSize

  init(_ metaData: CommandViewModel.MetaData,
       model: CommandViewModel.Kind.ChatGptModel,
       iconSize: CGSize,
       onAction: @escaping (Action) -> Void) {
    self.metaData = metaData
    self.model = model
    self.iconSize = iconSize
    self.onAction = onAction
  }

  var body: some View {
    CommandContainerView(
      metaData,
      placeholder: model.placeholder,
      icon: { metaData in
        KeyboardCowboyAsset.chatgpt.swiftUIImage.resizable()
          .frame(width: iconSize.width, height: iconSize.height)
      }, content: { metaData in
        ChatGptCommandContentView(model, onAction: onAction)
          .roundedContainer(4, padding: 0, margin: 0)
      }, onAction: { onAction(.commandAction($0)) })
    .enableInjection()
  }
}

private struct ChatGptCommandContentView: View {
  @State var model: CommandViewModel.Kind.ChatGptModel
  private let onAction: (ChatGptCommandView.Action) -> Void
  private let debounce: DebounceManager<String>

  init(_ model: CommandViewModel.Kind.ChatGptModel, onAction: @escaping (ChatGptCommandView.Action) -> Void) {
    self.model = model
    self.onAction = onAction
    debounce = DebounceManager(for: .milliseconds(500)) { newInput in
      onAction(.updatePromt(newPromt: newInput))
    }
  }

  var body: some View {
    ZenTextEditor(
      color: ZenColorPublisher.shared.color,
      text: $model.promt,
      placeholder: "Enter promt...", onCommandReturnKey: nil)
    .onChange(of: model.promt) { debounce.send($0) }
  }
}

struct ChatGptCommandView_Previews: PreviewProvider {
  static let command = DesignTime.chatGptCommand
  static var previews: some View {
    ChatGptCommandView(command.model.meta, model: command.kind, iconSize: .init(width: 24, height: 24)) { _ in }
      .designTime()
      .frame(idealHeight: 120, maxHeight: 180)
  }
}

