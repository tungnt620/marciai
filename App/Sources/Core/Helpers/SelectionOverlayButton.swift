import SwiftUI

struct SelectionOverlayButton: View {
    @State private var buttonPosition: CGPoint = .zero
    @State private var isButtonVisible: Bool = false
  @StateObject var textSelectionObserver = TextSelectionObserver.shared

  
  
    var body: some View {
        ZStack {
            if isButtonVisible {
                Button(action: {
                    print("Button clicked")
                }) {
                    Text("Action")
                        .padding(5)
                        .background(Color.gray.opacity(0.8))
                        .cornerRadius(5)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 400)
                }
                .position(buttonPosition)
                .onAppear {
                    // Adjust button size to match selected text
                    self.adjustButtonPosition()
                }
            }
        }
        .onChange(of: textSelectionObserver.currentSelectedText) { newSelection in
          print(newSelection.isEmpty)
            if !newSelection.isEmpty {
                self.isButtonVisible = true
                // Adjust position based on selection
                self.adjustButtonPosition()
            } else {
                self.isButtonVisible = false
            }
        }
    }

    private func adjustButtonPosition() {
        // Here, you'd compute the location of the selected text
        // For example, positioning it dynamically
        // Set the buttonPosition to the right of the selected text
        self.buttonPosition = CGPoint(x: 100, y: 100) // Replace with actual logic
    }
}
