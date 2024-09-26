import UniformTypeIdentifiers

extension UTType {
  static var group: UTType {
    UTType(exportedAs: "com.tung.MarciAI.Group", conformingTo: .json)
  }

  static var workflow: UTType {
    UTType(exportedAs: "com.tung.MarciAI.Workflows", conformingTo: .json)
  }

  static var command: UTType {
    UTType(exportedAs: "com.tung.MarciAI.Command", conformingTo: .json)
  }

  static var keyboardShortcut: UTType {
    UTType(exportedAs: "com.tung.MarciAI.KeyboardShortcut", conformingTo: .json)
  }

  static var applicationTrigger: UTType {
    UTType(exportedAs: "com.tung.MarciAI.ApplicationTrigger", conformingTo: .json)
  }
}
