import Foundation
import Supabase
import IOKit
import Carbon
import Cocoa
import KeyCodes
import Foundation
import SwiftUI
import MarkdownUI
import Combine


public struct Event: Encodable, Sendable {
  let action_type: String
  var detail: String = ""
  var metadata: [String: String] = Dictionary()
}

private struct EventSupabase: Encodable, Sendable {
  let device_id: String
  let action_type: String
  let detail: String
  var metadata: String
}


class GlobalUtils {
  static let shared = GlobalUtils()
  
  static let myApiKey = ""
  
  let apiLimiter: ApiUsageLimiter = ApiUsageLimiter(limitPerDuration: 50, durationInDays: 7) // Limit to 100 API calls per 7 days
  private let client: SupabaseClient
  let deviceId = getDeviceID()
  
  private init() {
    client = SupabaseClient(
      supabaseURL: URL(string: "https://aklfehkrmhcavboddvzg.supabase.co")!,
      supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrbGZlaGtybWhjYXZib2RkdnpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgwNzQyMjUsImV4cCI6MjA0MzY1MDIyNX0.DCThrBNJeKsuMKrl7N6yVNnN9YNN-U4mtGp2VWBMJX0"
    )
  }
  
  public func insertEvent(event: Event) async {
    do {
      
      let metaData = await ["buildNumber": KeyboardCowboy.buildNumber, "version": KeyboardCowboy.marketingVersion]
        .merging(event.metadata) { (_, new) in new }
      
      let metadataJsonData = try await JSONSerialization.data(
        withJSONObject: metaData
        , options: []
      )
      if let jsonString = String(data: metadataJsonData, encoding: .utf8) {
        let eventSupabase = EventSupabase(device_id: deviceId,
                                          action_type: event.action_type,
                                          detail: event.detail,
                                          metadata: jsonString
        )
        try await client.from("events").insert(eventSupabase).execute()
      }
    } catch {
      print("Error when send tracking: \(error.localizedDescription)")
    }
  }
  
}

func getDeviceID() -> String {
  let userDefaults = UserDefaults.standard
  if let storedUUID = userDefaults.string(forKey: "device_id") {
    // Return the stored UUID
    return storedUUID
  } else {
    // Generate a new UUID
    let newUUID = UUID().uuidString
    // Store the new UUID in UserDefaults
    userDefaults.set(newUUID, forKey: "device_id")
    return newUUID
  }
}

func simulateCopyShortcut(keyboardCommandRunner: KeyboardCommandRunner) async  throws{
  try await Task.sleep(for: .milliseconds(10))
  try keyboardCommandRunner.machPort?.post(kVK_ANSI_C, type: .keyDown, flags: .maskCommand)
  try keyboardCommandRunner.machPort?.post(kVK_ANSI_C, type: .keyUp, flags: .maskCommand)
  try await Task.sleep(for: .milliseconds(10))
  try keyboardCommandRunner.machPort?.post(kVK_ANSI_C, type: .keyDown, flags: .maskCommand)
  try keyboardCommandRunner.machPort?.post(kVK_ANSI_C, type: .keyUp, flags: .maskCommand)
  try await Task.sleep(for: .milliseconds(10))
  try keyboardCommandRunner.machPort?.post(kVK_ANSI_C, type: .keyDown, flags: .maskCommand)
  try keyboardCommandRunner.machPort?.post(kVK_ANSI_C, type: .keyUp, flags: .maskCommand)
  try await Task.sleep(for: .milliseconds(50))
}

func fetchSelectedTextFromPasteboard() -> String {
  let pasteboard = NSPasteboard.general
  var selectedText = ""
  
  // Retrieve Plain Text
  if let plainText = pasteboard.string(forType: .string), !plainText.isEmpty {
    selectedText = plainText
  }
  
  // Retrieve Rich Text (RTF)
  if let rtfData = pasteboard.data(forType: .rtf),
     let rtfString = NSAttributedString(rtf: rtfData, documentAttributes: nil),
     !rtfString.string.isEmpty {
    selectedText = rtfString.string
  }
  
  // Retrieve HTML Text
  if let htmlData = pasteboard.data(forType: .html),
     let htmlString = String(data: htmlData, encoding: .utf8),
     let attributedString = try? NSAttributedString(
      data: Data(htmlString.utf8),
      options: [.documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue],
      documentAttributes: nil),
     !attributedString.string.isEmpty {
    selectedText = attributedString.string
  }
  
  return selectedText
}

func copyTextToPasteboard(text: String) {
  // Get the general pasteboard
  let pasteboard = NSPasteboard.general
  
  // Clear any existing contents
  pasteboard.clearContents()
  
  // Set the string to the pasteboard
  pasteboard.setString(text, forType: .string)
}
