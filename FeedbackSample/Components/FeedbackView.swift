import SwiftUI
import Combine

typealias Feedback = (message: LocalizedStringKey, type: FeedbackType)

enum FeedbackType {
  case success
  case error
}

struct FeedbackView: View {
  let message: LocalizedStringKey
  let type: FeedbackType

  private var backgroundColor: Color {
    switch type {
    case .success:
      return .green
    case .error:
      return .red
    }
  }

  var body: some View {
    Text(message)
      .padding()
      .background(backgroundColor)
      .foregroundColor(.white)
      .cornerRadius(8)
      .frame(maxWidth: .infinity, minHeight: 40)
      .padding(.horizontal, 16)
  }
}


