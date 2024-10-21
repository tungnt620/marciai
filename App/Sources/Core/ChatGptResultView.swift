import SwiftUI

struct ChatGptResultView: View {
  @StateObject var viewModel = ChatGptResultViewModel()
  let input: String
  let selectedText: String
  @State private var showCopiedText = false
  
  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      ScrollView {
        CodeSyntaxHighlightView(markdownContent: viewModel.markdownContent)
          .padding()
          .textSelection(.enabled)
          .frame(maxWidth: .infinity)
      }
      .onAppear {
        viewModel.fetchChatGptResult(input: input, selectedText: selectedText)
      }
      
      VStack(alignment: .center) {
        if showCopiedText {
          Text("Copied!")
            .font(.caption)
            .transition(.opacity)
            .padding(.bottom, 8)
        }
        
        Button(action: {
          copyToClipboard(markdownContent: viewModel.markdownContent)
          showCopiedFeedback()
        }) {
          Image(systemName: "doc.on.doc")
            .resizable()
            .frame(width: 12, height: 12)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
            .shadow(radius: 3)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.trailing)
        .padding(.bottom)
      }
    }
  }
  
  func copyToClipboard(markdownContent: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(markdownContent, forType: .string)
  }
  
  func showCopiedFeedback() {
    withAnimation {
      showCopiedText = true
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      withAnimation {
        showCopiedText = false
      }
    }
  }
}