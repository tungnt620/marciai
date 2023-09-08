import Combine
import Foundation

protocol DebounceSnapshot: Equatable { }

final class DebounceSelectionManager<Snapshot: DebounceSnapshot> {
  private var subscription: AnyCancellable?
  private let subject = PassthroughSubject<Snapshot, Never>()
  private let onUpdate: (Snapshot) -> Void
  @Published var snapshot: Snapshot

  init(_ initialValue: Snapshot, milliseconds: Int, onUpdate: @escaping (Snapshot) -> Void) {
    self._snapshot = .init(initialValue: initialValue)
    self.onUpdate = onUpdate
    self.subscription = subject
      .dropFirst()
      .removeDuplicates()
      .debounce(for: .milliseconds(milliseconds), scheduler: DispatchQueue.main)
      .sink { onUpdate($0) }
  }

  func process(_ snapshot: Snapshot) {
    if NSEventController.shared.keyDown {
      subject.send(snapshot)
    } else {
      onUpdate(snapshot)
    }
  }
}
