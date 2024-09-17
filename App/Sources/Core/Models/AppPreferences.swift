import Cocoa

private let rootFolder = URL(fileURLWithPath: #file).pathComponents
  .prefix(while: { $0 != "KeyboardCowboy" })
  .joined(separator: "/")
  .dropFirst()

// TODO: hard code configuration for ReWrite application

struct AppPreferences {
  var hideAppOnLaunch: Bool = true
  var machportIsEnabled = true
  var storageConfiguration: any StoringConfiguration

  private static func filename(for functionName: StaticString) -> String {
    "\(functionName)"
      .replacingOccurrences(of: "()", with: "")
      .appending(".json")
  }

  static func user() -> AppPreferences {
    AppPreferences(
      hideAppOnLaunch: true,
      machportIsEnabled: true,
      storageConfiguration: StorageConfiguration(path: "~/", filename: ".keyboard-cowboy.json"))
//      // Hard code the configuration file
//      // At first version we only allow user config one configuration and one group
//      // In a group can have multiple workflow
//      storageConfiguration: StorageConfiguration(path: rootFolder.appending("/KeyboardCowboy/Fixtures/json"),
//                                                 filename: filename(for: #function)))
  }

  static func development() -> AppPreferences {
    AppPreferences(
      hideAppOnLaunch: false,
      machportIsEnabled: true,
      storageConfiguration: StorageConfiguration(path: "~/", filename: ".keyboard-cowboy.json"))
  }

  static func emptyFile() -> AppPreferences {
    AppPreferences(
      hideAppOnLaunch: false,
      machportIsEnabled: false,
      storageConfiguration: StorageConfiguration(path: rootFolder.appending("/KeyboardCowboy/Fixtures/json"),
                                                 filename: filename(for: #function)))
  }

  static func noConfiguration() -> AppPreferences {
    AppPreferences(
      hideAppOnLaunch: false,
      machportIsEnabled: false,
      storageConfiguration: StorageConfiguration(path: rootFolder.appending("//jsonKeyboardCowboy/Fixtures"),
                                                 filename: filename(for: #function)))
  }

  static func noGroups() -> AppPreferences {
    AppPreferences(
      hideAppOnLaunch: false,
      machportIsEnabled: false,
      storageConfiguration: StorageConfiguration(path: rootFolder.appending("/KeyboardCowboy/Fixtures/json"),
                                                 filename: filename(for: #function)))

  }

  static func designTime() -> AppPreferences {
    AppPreferences(
      hideAppOnLaunch: false,
      machportIsEnabled: true,
      storageConfiguration: StorageConfiguration(path: rootFolder.appending("/KeyboardCowboy/Fixtures/json"),
                                                 filename: filename(for: #function)))
  }

  static func performance() -> AppPreferences {
    AppPreferences(
      hideAppOnLaunch: false,
      machportIsEnabled: false,
      storageConfiguration: StorageConfiguration(path: rootFolder.appending("/KeyboardCowboy/Fixtures/json"),
                                                 filename: filename(for: #function)))

  }
}
