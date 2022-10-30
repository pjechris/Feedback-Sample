import Foundation
import Combine
import SwiftUI

/// Modifier sending a feedback to a container.
/// Essentially same role as `NavigationLink` when in tandem with `NavigationView`
struct FeedbackSenderModifier<P: Publisher>: ViewModifier where P.Failure == Never {
    let publisher: P
    let message: (P.Output) -> Feedback?
    
    @EnvironmentObject var notifier: FeedbackNotifier
    
    func body(content: Content) -> some View {
        content
            .onReceive(publisher) { output in
                guard let feedback = message(output) else {
                    return
                }
                
                notifier.feedback = feedback
            }
    }
}

extension View {
    /// send a publisher output as feedback
    /// - Parameter publisher: the publisher to listen to
    /// - Parameter message: the feedback message to generate. nil if no message should be generated for this output
    func sendFeedback<P: Publisher>(publisher: P, message: @escaping (P.Output) -> Feedback?)
    -> some View where P.Failure == Never {
        modifier(FeedbackSenderModifier(publisher: publisher, message: message))
    }
    
    /// send a publisher output as success feedback
    /// - Parameter publisher: the publisher to listen to
    /// - Parameter message: the success message to display
    func sendFeedback<P: Publisher>(publisher: P, message: @escaping (P.Output) -> LocalizedStringKey?)
    -> some View where P.Failure == Never {
        sendFeedback(publisher: publisher) { message($0).map { (message: $0, type: .success) } }
    }
    
    func sendFeedback<P: Publisher, Output>(publisher: P, message: @escaping (Output) -> LocalizedStringKey?)
    -> some View where P.Output == Output?, P.Failure == Never {
        sendFeedback(publisher: publisher.compactMap { $0 }, message: message)
    }
    
    /// send a publisher error as failure feedback
    func sendFeedback(error: some Publisher<Error, Never>) -> some View {
        sendFeedback(publisher: error) { error in
            switch error {
            case is LocalizedError:
                return (message: LocalizedStringKey(error.localizedDescription), type: .error)
            default:
                return (message: "error_default", type: .error)
            }
        }
    }
    
    func sendFeedback(error: some Publisher<Error?, Never>) -> some View {
        sendFeedback(error: error.compactMap { $0 })
    }
    
    func sendFeedback<P: Publisher, Success, Failure: Error>(publisher: P, message: @escaping (Success) -> LocalizedStringKey?)
    -> some View where P.Output == Result<Success, Failure>, P.Failure == Never {
        
        sendFeedback(publisher: publisher) {
            switch $0 {
            case let .success(output):
                return message(output).map { (message: $0, type: .success) }
            case let .failure(error) where error is LocalizedError:
                return (message: LocalizedStringKey(error.localizedDescription), type: .error)
            case .failure:
                return (message: "error_default", type: .error)
            }
        }
    }
}
