import Bonzai
import SwiftUI

struct NewCommandChatGptView: View {
  private let wikiUrl = URL(string: "https://github.com/zenangst/KeyboardCowboy/wiki/Commands#type-commands")!
  @Binding private var payload: NewCommandPayload
  @Binding private var validation: NewCommandValidation
  @State private var promt: String = ""

  init(_ payload: Binding<NewCommandPayload>, validation: Binding<NewCommandValidation>) {
    _payload = payload
    _validation = validation
  }

  var body: some View {
    HStack {
      ZenLabel("ChatGpt Command:")
      Spacer()
    }
    
    VStack(alignment: .leading) {
      ZenTextEditor(text: $promt, placeholder: "Enter promt…")
    }
    .onAppear {
      validation = .valid
      updatePayload()
    }
    .onChange(of: self.promt, perform: { newValue in
      updatePayload()
    })
  }
  
  
  private func updatePayload() {
    payload = .chatGpt(promt: promt)
  }
}

struct NewCommandChatGptView_Previews: PreviewProvider {
  static var previews: some View {
    NewCommandView(
      workflowId: UUID().uuidString,
      commandId: nil,
      title: "New chat gpt command",
      selection: .text,
      payload: .placeholder,
      onDismiss: {},
      onSave: { _, _ in })
    .designTime()
  }
}
