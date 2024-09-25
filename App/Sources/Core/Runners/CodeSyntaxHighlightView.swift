import MarkdownUI
import Splash
import SwiftUI

struct CodeSyntaxHighlightView: View {
  @Environment(\.colorScheme) private var colorScheme
  
  let markdownContent: String
  
  var body: some View {
    Markdown(self.markdownContent)
      .markdownBlockStyle(\.codeBlock) {
        codeBlock($0)
      }
  }
  
  @ViewBuilder
  private func codeBlock(_ configuration: CodeBlockConfiguration) -> some View {
    VStack(spacing: 0) {
      HStack {
        Text(configuration.language ?? "plain text")
          .font(.system(.caption, design: .monospaced))
          .fontWeight(.semibold)
          .foregroundColor(Color(theme.plainTextColor))
        Spacer()
        
        Image(systemName: "clipboard")
          .onTapGesture {
            copyToClipboard(configuration.content)
          }
      }
      .padding(.horizontal)
      .padding(.vertical, 1)
      .background {
        Color(theme.backgroundColor)
      }
      
      Divider()
      
      ScrollView(.horizontal) {
        configuration.label
          .relativeLineSpacing(.em(0.25))
          .markdownTextStyle {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.85))
          }
          .padding()
      }
    }
    //    .background(Color())
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .markdownMargin(top: .zero, bottom: .em(0.5))
  }
  
  private var theme: Splash.Theme {
    // NOTE: We are ignoring the Splash theme font
    switch self.colorScheme {
    case .dark:
      return .wwdc17(withFont: .init(size: 16))
    default:
      return .sunset(withFont: .init(size: 16))
    }
  }
  
  private func copyToClipboard(_ string: String) {
    print(string)
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(string, forType: .string)
  }
}

struct CodeSyntaxHighlightView_Previews: PreviewProvider {
  static var previews: some View {
    CodeSyntaxHighlightView(markdownContent: "132132")
  }
}
