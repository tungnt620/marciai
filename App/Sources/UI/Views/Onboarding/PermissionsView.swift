import SwiftUI
import Bonzai

struct PermissionsView: View {
  enum Action {
    case github
    case requestPermissions
  }
  @State var animated: Bool = false
  @State var done: Bool = false

  var onAction: (Action) -> Void

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 16) {
        KeyboardCowboyAsset.applicationIcon.swiftUIImage
          .resizable()
          .frame(width: 84, height: 84)
        Text("Accessibility permissions are required for MarciAI application to function properly.")
          .font(.title2)
      }
      .padding([.leading, .top, .trailing], 16)

      ZenDivider()

      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Group {
            Text("This allows our application to record hotkeys and perform other actions.")
            Text("Rest assured that we do not use this information for any purpose other than to serve you.")
          }
          .font(.headline)
          Text("MarciAI comes with built-in security measures to protect your sensitive information. Password fields and other secure inputs cannot be monitored by our application.")
          Text("MarciAI is designed to be secure and private.")
            .font(.headline)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      }
      .background(Color.black.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 8)))

      ZenDivider()
      
      HStack(spacing: 16) {
        Button("Request permission", action: {
          done.toggle()
          onAction(.requestPermissions)
        })
        .buttonStyle(.positive)
      }
      .roundedContainer()
    }
    .compositingGroup()
    .frame(minHeight: 300, maxHeight: .infinity, alignment: .top)
    .background(SplashView(done: $done))
    .onAppear {
      animated = true
    }
  }
}

struct PermissionsView_Previews: PreviewProvider {
    static var previews: some View {
      PermissionsView(onAction: { _ in })
        .previewLayout(.sizeThatFits)
    }
}
