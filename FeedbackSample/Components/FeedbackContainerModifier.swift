import SwiftUI
import Combine

@MainActor
class FeedbackNotifier: ObservableObject {
  @Published var feedback: Feedback?
}

/// Container listening to `FeedbackNotifier` and displaying notifications.
/// Essentially work the same way as `NavigationView`
struct FeedbackContainerModifier: ViewModifier {

  @StateObject private var notifier = FeedbackNotifier()

  @State private var timer = Timer.publish(every: 4, on: .main, in: .common)
  @State private var feedback: Feedback?
  @State private var cancellable: Cancellable?

  func body(content: Content) -> some View {
    content
      .environmentObject(notifier)
      .overlay(alignment: .top) {
        if let feedback = feedback {
          FeedbackView(message: feedback.message, type: feedback.type)
        }
      }
      .onReceive(notifier.$feedback) { newFeedback in
        timer = Timer.publish(every: 4, on: .main, in: .common)
        cancellable = timer.connect()

        feedback = newFeedback
      }
      .onReceive(timer) { _ in
        feedback = nil
        cancellable?.cancel()
      }
  }
}

extension View {
  func feedbackContainer() -> some View {
    modifier(FeedbackContainerModifier())
  }
}
