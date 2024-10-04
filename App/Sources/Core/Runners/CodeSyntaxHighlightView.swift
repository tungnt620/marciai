import MarkdownUI
import Splash
import SwiftUI

struct CodeSyntaxHighlightView: View {
  @Environment(\.colorScheme) private var colorScheme
  @State private var showCopiedText = false  // State to control "Copied!" message visibility

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
        
        
        // "Copied!" helper text
        if showCopiedText {
          Text("Copied!")
            .font(.caption)
            .transition(.opacity)  // Fade in/out
        }
        
        Image(systemName: "doc.on.doc")  // Clipboard icon
          .resizable()
          .scaledToFit()
          .frame(width: 30, height: 30)
          .padding(5)
          .onTapGesture {
            copyToClipboard(configuration.content)
            showCopiedFeedback()  // Show "Copied!" message
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
    .background(Color(theme.backgroundColor))
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .markdownMargin(top: .zero, bottom: .em(0.5))
  }
  
  // Function to show "Copied!" helper text for a short duration
  func showCopiedFeedback() {
    withAnimation {
      showCopiedText = true  // Show the "Copied!" text with animation
    }
    
    // Hide the message after 2 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      withAnimation {
        showCopiedText = false
      }
    }
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
    CodeSyntaxHighlightView(markdownContent: """
  ```swift
          private func copyToClipboard(_ string: String) {
            print(string)
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(string, forType: .string)
          }
  ```
  """)
  }
}
