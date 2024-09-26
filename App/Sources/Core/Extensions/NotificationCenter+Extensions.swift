import Foundation

extension Notification {
  @MainActor static let openKeyboardCowboy = Notification(name: .openKeyboardCowboy)
}

extension Notification.Name {
  static let newWorkflow = AppNotification.newWorkflow.notificationName
  static let openKeyboardCowboy = AppNotification.openKeyboardCowboy.notificationName
}

enum AppNotification: String {
  case newWorkflow = "com.tung.MarciAI.newWorkflow"
  case openKeyboardCowboy = "com.tung.MarciAI.openApp"

  var notificationName: Notification.Name { Notification.Name(rawValue) }
}

extension NotificationCenter {
  func post(_ appNotification: AppNotification) {
    post(name: appNotification.notificationName, object: nil)
  }
}
