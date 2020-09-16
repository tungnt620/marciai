import Foundation
import LogicFramework
import Carbon

class HotkeyHandlerMock: HotkeyHandling {
  typealias Handler = (State) -> Void

  var delegate: HotkeyHandlerDelegate?
  var hotkeySupplier: HotkeySupplying?
  var handler: Handler
  var registerResult: Bool

  enum State {
    case installHandler
    case register(_ hotkey: Hotkey, signature: String)
    case sendKeyboardEvent(hotkeys: Set<Hotkey>)
    case unregister
  }

  init(registerResult: Bool, handler: @escaping Handler) {
    self.handler = handler
    self.registerResult = registerResult
  }

  func installEventHandler() {
    handler(.installHandler)
  }

  func register(_ hotkey: Hotkey, withSignature signature: String) -> Bool {
    handler(.register(hotkey, signature: signature))
    return registerResult
  }

  func sendKeyboardEvent(_ event: EventRef, hotkeys: Set<Hotkey>) -> OSStatus {
    handler(.sendKeyboardEvent(hotkeys: hotkeys))
    return noErr
  }

  func unregister(_ reference: EventHotKeyRef) {
    handler(.unregister)
  }
}
