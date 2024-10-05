import Bonzai
import SwiftUI

struct ContentChatGptImageView: View {
  let size: CGFloat

  var body: some View {
    KeyboardCowboyAsset.chatgpt.swiftUIImage
      .resizable()
      .frame(width: size, height: size)
  }
}

struct ContentChatGptImageView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentChatGptImageView(size: 32)
    }
    .frame(minWidth: 200, minHeight: 120)
    .padding()
  }
}
