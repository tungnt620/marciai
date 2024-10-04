import SwiftUI
import Foundation

class ApiUsageLimiter: ObservableObject {
  @AppStorage("Setting.chatGPTApiCallCount") var apiCallCount: Int = 0
  @AppStorage("Setting.chatGPTApiStartTime") var apiStartTime: TimeInterval = Date().timeIntervalSince1970
  private let limitPerDuration: Int
  private let durationInSeconds: TimeInterval
  
  init(limitPerDuration: Int, durationInDays: Int) {
    self.limitPerDuration = limitPerDuration
    // Convert the duration from days to seconds
    self.durationInSeconds = TimeInterval(durationInDays * 24 * 60 * 60)
    checkAndResetIfNecessary()
  }
  
  // Function to check if API call can be made
  func canMakeApiCall() -> Bool {
    let now = Date()
    print("Current API usage limit: \(apiCallCount), \(apiStartTime)")
    
    // Check if the custom duration window has passed
    let startTime = Date(timeIntervalSince1970: apiStartTime)
    if now.timeIntervalSince(startTime) >= durationInSeconds {
      resetUsage()
      print("Usage data reset. API call count: 0")
      return true
    } else {
      // Check if the API call count is within the limit
      if apiCallCount < limitPerDuration {
        apiCallCount += 1
        return true
      } else {
        print("API usage limit of \(limitPerDuration) calls in the set duration has been reached.")
        return false
      }
    }
  }
  
  private func resetUsage() {
    apiCallCount = 0
    apiStartTime = Date().timeIntervalSince1970
  }
  
  private func checkAndResetIfNecessary() {
    let now = Date()
    let startTime = Date(timeIntervalSince1970: apiStartTime)
    if now.timeIntervalSince(startTime) >= durationInSeconds {
      resetUsage()
    }
  }
}
