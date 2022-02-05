import Apps
import SwiftUI

struct ApplicationTriggerListView: View {
  enum Action {
    case add(Application)
    case remove(Application)
  }
  let action: (Action) -> Void
  @ObservedObject var applicationStore: ApplicationStore
  @Binding var applicationTriggers: [ApplicationTrigger]
  @State var selection: String = ""

  var body: some View {
    VStack {
      HStack {
        Picker("Application",
               selection: $selection,
               content: {
          ForEach(applicationStore.applications.filter({ application in
            !applicationTriggers
              .compactMap({ $0.application.bundleIdentifier })
              .contains(application.bundleIdentifier)
          }), id: \.bundleIdentifier) { application in
            Text(application.displayName)
              .id(application.bundleIdentifier)
          }
        })
        Button("Add") {
          guard let application = applicationStore.applications.first(where: {
            $0.bundleIdentifier == selection
          }) else { return }
          action(.add(application))
        }
      }
      Spacer()
      ForEach($applicationTriggers) { applicationTrigger in
        HStack {
          ApplicationTriggerView(trigger: applicationTrigger)
          Button(action: { action(.remove(applicationTrigger.application.wrappedValue)) },
                 label: { Image(systemName: "xmark.circle") })
          .buttonStyle(PlainButtonStyle())
        }
      }
    }
  }

  @ViewBuilder
  func contextView(_ contexts: Set<ApplicationTrigger.Context>) -> some View {
    HStack(spacing: 1) {
      if contexts.contains(.closed) {
        Circle().fill(Color(.systemRed))
          .frame(width: 6)
      }
      if contexts.contains(.launched) {
        Circle().fill(Color(.systemYellow))
          .frame(width: 6)
      }
      if contexts.contains(.frontMost) {
        Circle().fill(Color(.systemGreen))
          .frame(width: 6)
      }
    }
    .frame(height: 10)
    .padding(.horizontal, 1)
    .overlay(
      RoundedRectangle(cornerRadius: 4)
        .stroke(Color(NSColor.systemGray.withSystemEffect(.disabled)), lineWidth: 1)
    )
    .opacity(0.8)
  }
}

struct ApplicationTriggerListView_Previews: PreviewProvider {
  static var previews: some View {
    ApplicationTriggerListView(
      action: { _ in },
      applicationStore: ApplicationStore(),
      applicationTriggers: .constant([]))
  }
}
