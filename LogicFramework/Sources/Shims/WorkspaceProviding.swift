import Cocoa

public typealias WorkspaceCompletion = ((RunningApplication?, Error?) -> Void)
public protocol WorkspaceProviding {
  var applications: [RunningApplication] { get }
  var frontApplication: RunningApplication? { get }

  func launchApplication(withBundleIdentifier bundleIdentifier: String,
                         options: NSWorkspace.LaunchOptions,
                         additionalEventParamDescriptor descriptor: NSAppleEventDescriptor?,
                         launchIdentifier identifier: AutoreleasingUnsafeMutablePointer<NSNumber?>?) -> Bool

  func open(_ url: URL,
            config: NSWorkspace.OpenConfiguration,
            completionHandler: ((RunningApplication?, Error?) -> Void)?)

  func open(_ urls: [URL], withApplicationAt applicationURL: URL,
            config: NSWorkspace.OpenConfiguration,
            completionHandler: ((RunningApplication?, Error?) -> Void)?)

  func reveal(_ path: String)
}

extension NSWorkspace: WorkspaceProviding {
  public var applications: [RunningApplication] {
    return runningApplications
  }

  public var frontApplication: RunningApplication? {
    return frontmostApplication
  }

  public func open(_ url: URL,
                   config: NSWorkspace.OpenConfiguration,
                   completionHandler: WorkspaceCompletion?) {
    open(url, configuration: config) { (runningApplication, error) in
      completionHandler?(runningApplication, error)
    }
  }

  public func open(_ urls: [URL], withApplicationAt applicationUrl: URL,
                   config: NSWorkspace.OpenConfiguration,
                   completionHandler: WorkspaceCompletion?) {
    open(urls, withApplicationAt: applicationUrl, configuration: config) { (runningApplication, error) in
      completionHandler?(runningApplication, error)
    }
  }

  public func reveal(_ path: String) {
    selectFile(path, inFileViewerRootedAtPath: "")
  }
}
