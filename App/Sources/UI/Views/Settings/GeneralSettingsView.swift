import Bonzai
import SwiftUI

struct GeneralSettingsView: View {
  @AppStorage("Setting.chatGptApiKey") var chatGptApiKey: String = ""
  
  var body: some View {
    VStack(alignment: .center) {
      Text("ChatGPT API key")
      TextField("ChatGPT API key", text: $chatGptApiKey)
        .textFieldStyle(.regular(Color(.windowBackgroundColor)))
      .padding()
    }
    .frame(minWidth: 480, minHeight: 100, alignment: .center)
      .roundedContainer()
  }
}

struct GeneralSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    GeneralSettingsView()
  }
}
