import Foundation

enum ChallengeState {
    case started
    case loading
    case finished(Result<Bool, Error>)
}

