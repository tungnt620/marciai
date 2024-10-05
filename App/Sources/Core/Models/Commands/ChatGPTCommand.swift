import Foundation

/// This command is used to send user prompts to ChatGPT
/// and receive responses.
struct ChatGptCommand: MetaDataProviding {
    /// The user's prompt that will be sent to ChatGPT.
    var prompt: String
    /// Optional metadata for the command.
    var meta: Command.MetaData

    public init(id: String = UUID().uuidString,
                name: String = "ChatGpt command",
                prompt: String,
                notification: Command.Notification? = nil) {
        self.prompt = prompt
        self.meta = Command.MetaData(id: id, name: name, isEnabled: true, notification: notification)
    }

    init(prompt: String, meta: Command.MetaData) {
        self.prompt = prompt
        self.meta = meta
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.prompt = try container.decode(String.self, forKey: .prompt)

        do {
            self.meta = try container.decode(Command.MetaData.self, forKey: .meta)
        } catch {
            self.meta = try MetaDataMigrator.migrate(decoder)
        }
    }

    func copy() -> ChatGptCommand {
        ChatGptCommand(prompt: prompt, meta: meta.copy())
    }
}
