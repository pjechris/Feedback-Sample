import SwiftUI

@main
struct FeedbackTestApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                GameView(viewModel: GameViewModel())
            }
            .feedbackContainer()
        }
    }
}

class GameViewModel: ObservableObject {
    @Published var lastUserRating: Int = 0
    @Published var error: Error?
    @Published var errorMode = false
    
    func simulateRating(_ rating: Int) {
        guard errorMode == false else {
            error = RatingError.ratingIsClosed
            return
        }
        
        lastUserRating = rating
        error = nil
    }
}

enum RatingError: Error {
    case ratingIsClosed
}

/// This view will show:
/// - A message everytime the game is rated
/// - A very specific message first time the game is rated
/// - A message everytime there is an error
struct GameView: View {
    @StateObject var viewModel: GameViewModel
    
    var body: some View {
        return VStack(spacing: 16) {
            Spacer()
            
            RateView(rating: viewModel.lastUserRating, onRate: viewModel.simulateRating)

            Button("Tap on this method to \(viewModel.errorMode ? "disable" : "trigger") errrors") {
                viewModel.errorMode.toggle()
            }
            .padding(8)
            .border(viewModel.errorMode ? .red : .green)
            .foregroundColor(viewModel.errorMode ? .red : .green)
            
            Spacer()
        }
        .sendFeedback(publisher: viewModel.$lastUserRating.filter { $0 > 0 }) { _ in "Your rating was updated" }
        .sendFeedback(error: viewModel.$error)
        .navigationTitle("God of War: Ragnarök")
    }
}

struct RateView: View {
    let rating: Int
    let onRate: (Int) -> Void
    
    var body: some View {
        HStack {
            ForEach(1..<6) { i in
                Button(
                    action: { onRate(i) },
                    label: { Image(systemName: i <= rating ? "star.fill" : "star") }
                )
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(viewModel: GameViewModel())
    }
}

@MainActor
class TestViewModel: ObservableObject {
    @Published var isFinished: Result<Bool, Error> = .success(false)
    
    func set(output: Bool) {
        self.isFinished = .success(output)
    }
    
    func set(error: Error) {
        self.isFinished = .failure(error)
    }
}
