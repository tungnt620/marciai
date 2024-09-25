import Foundation
import AppKit

class ChatGPTClient: NSObject, URLSessionDataDelegate {

    private var session: URLSession?
    private var task: URLSessionDataTask?
    private var escKeyMonitor: Any? // Store the escKeyMonitor globally
    private let apiKey: String
    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!

    init(apiKey: String) {
        self.apiKey = apiKey
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }

    // Start the streaming request using GPT-4-turbo and pass a custom handler for processing chunks and errors
    func startChat(with messages: [[String: Any]], onMessageReceived: @escaping (String, @escaping () -> Void) -> Void, onError: @escaping (String) -> Void) {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // The body of the request
        let requestBody: [String: Any] = [
            "model": "gpt-4o", // Updated model to gpt-4-turbo-0613 for better performance.
            "messages": messages, // Chat history in the expected format.
            "stream": true // Enable streaming response
        ]

        // Serialize the request body
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        // Save the custom message and error handlers
        self.messageHandler = onMessageReceived
        self.errorHandler = onError

        // Start the task
        task = session?.dataTask(with: request)
        task?.resume()
    }

    // Stop the SSE connection and remove the Esc key listener
    func stopChat() {
        task?.cancel()
        print("Chat stopped.")

        // Remove the Esc key listener if it exists
        if let monitor = escKeyMonitor {
            NSEvent.removeMonitor(monitor)
            escKeyMonitor = nil // Clear the reference
            print("Esc key listener removed.")
        }
    }

    // Handle incoming data from the stream
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let eventString = String(data: data, encoding: .utf8) {
            processStreamedData(eventString)
        }
    }

    // A closure to handle received messages (provided by the caller)
    private var messageHandler: ((String, @escaping () -> Void) -> Void)?

    // A closure to handle errors (provided by the caller)
    private var errorHandler: ((String) -> Void)?

    // Process streamed chunks of data from GPT-4-turbo
    private func processStreamedData(_ event: String) {
        let lines = event.split(separator: "\n").map(String.init)

        for line in lines {
            if line.hasPrefix("data: ") {
                let jsonString = line.replacingOccurrences(of: "data: ", with: "")

                // Detect the end of the stream with `[DONE]`
                if jsonString == "[DONE]" {
                    print("Streaming completed")
                    stopChat() // Stop the chat when done
                    return
                }

                // Try to parse the JSON data
                if let jsonData = jsonString.data(using: .utf8) {
                    if let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        // Check for error in the JSON response
                        if let error = json["error"] as? [String: Any],
                           let errorMessage = error["message"] as? String {
                            errorHandler?(errorMessage) // Call the error handler
                            stopChat()
                        } else if let choices = json["choices"] as? [[String: Any]],
                                  let delta = choices.first?["delta"] as? [String: Any],
                                  let content = delta["content"] as? String {
                            messageHandler?(content) { [weak self] in
                                self?.stopChat()
                            }
                        }
                    }
                }
            }
        }
    }
}
