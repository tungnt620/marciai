import SwiftUI

struct CommandCenterContainerView: View {
  @Binding private var contentState: ContentStore.State
  enum Action {
    case openScene(AppScene)
    case sidebar(SidebarView.Action)
    case content(ContentView.Action)
    case detail(DetailView.Action)
  }
  
  private let applicationTriggerSelectionManager: SelectionManager<DetailViewModel.ApplicationTrigger>
  private let commandSelectionManager: SelectionManager<CommandViewModel>
  private let configSelectionManager: SelectionManager<ConfigurationViewModel>
  private let contentSelectionManager: SelectionManager<ContentViewModel>
  private let groupsSelectionManager: SelectionManager<GroupViewModel>
  private let keyboardShortcutSelectionManager: SelectionManager<KeyShortcut>
  private let publisher: ContentPublisher
  private let triggerPublisher: TriggerPublisher
  private let infoPublisher: InfoPublisher
  private let commandPublisher: CommandsPublisher
  private var focus: FocusState<AppFocus?>.Binding
  private let onAction: (Action) -> Void

  @MainActor
  init(_ focus: FocusState<AppFocus?>.Binding,
       contentState: Binding<ContentStore.State>,
       publisher: ContentPublisher,
       applicationTriggerSelectionManager: SelectionManager<DetailViewModel.ApplicationTrigger>,
       commandSelectionManager: SelectionManager<CommandViewModel>,
       configSelectionManager: SelectionManager<ConfigurationViewModel>,
       contentSelectionManager: SelectionManager<ContentViewModel>,
       groupsSelectionManager: SelectionManager<GroupViewModel>,
       keyboardShortcutSelectionManager: SelectionManager<KeyShortcut>,
       triggerPublisher: TriggerPublisher,
       infoPublisher: InfoPublisher,
       commandPublisher: CommandsPublisher,
       onAction: @escaping (Action) -> Void) {
    _contentState = contentState
    self.focus = focus
    self.publisher = publisher
    self.applicationTriggerSelectionManager = applicationTriggerSelectionManager
    self.commandSelectionManager = commandSelectionManager
    self.configSelectionManager = configSelectionManager
    self.contentSelectionManager = contentSelectionManager
    self.groupsSelectionManager = groupsSelectionManager
    self.keyboardShortcutSelectionManager = keyboardShortcutSelectionManager
    self.triggerPublisher = triggerPublisher
    self.infoPublisher = infoPublisher
    self.commandPublisher = commandPublisher
    self.onAction = onAction
  }

  var body: some View {
    NavigationSplitView(
      sidebar: {
        CommandCenterSidebarView(
          focus,
          configSelectionManager: configSelectionManager,
          groupSelectionManager: groupsSelectionManager,
          contentSelectionManager: contentSelectionManager,
          onAction: { onAction(.sidebar($0)) })
        .onChange(of: contentState, perform: { newValue in
          guard newValue == .initialized else { return }
          guard let groupId = groupsSelectionManager.lastSelection else { return }
          onAction(.sidebar(.selectGroups([groupId])))
        })
      },
      content: {
        CommandCenterContentView(
          focus,
          groupId: groupsSelectionManager.lastSelection ?? groupsSelectionManager.selections.first ?? "empty",
          contentSelectionManager: contentSelectionManager,
          onAction: {
            onAction(.content($0))
          })
      },
      detail: {
        CommandCenterResultView(
          focus,
          applicationTriggerSelectionManager: applicationTriggerSelectionManager,
          commandSelectionManager: commandSelectionManager,
          keyboardShortcutSelectionManager: keyboardShortcutSelectionManager,
          triggerPublisher: triggerPublisher,
          infoPublisher: infoPublisher,
          commandPublisher: commandPublisher,
          onAction: { onAction(.detail($0)) }
        )
      })
    .navigationSplitViewStyle(.balanced)
  }
}

struct CommandCenterContainerView_Previews: PreviewProvider {
  @FocusState static var focus: AppFocus?
  static var previews: some View {
    CommandCenterContainerView(
      $focus,
      contentState: .readonly(.initialized),
      publisher: DesignTime.contentPublisher,
      applicationTriggerSelectionManager: .init(),
      commandSelectionManager: .init(),
      configSelectionManager: .init(),
      contentSelectionManager: .init(),
      groupsSelectionManager: .init(),
      keyboardShortcutSelectionManager: .init(),
      triggerPublisher: DesignTime.triggerPublisher,
      infoPublisher: DesignTime.infoPublisher,
      commandPublisher: DesignTime.commandsPublisher
    ) { _ in }
      .designTime()
      .frame(height: 800)
  }
}
