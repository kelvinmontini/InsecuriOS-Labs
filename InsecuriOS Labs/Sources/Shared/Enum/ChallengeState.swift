import Foundation

enum ChallengeState: Equatable {
    case started
    case loading
    case finished(Result<Bool, Error>)
    
    static func == (lhs: ChallengeState, rhs: ChallengeState) -> Bool {
        switch (lhs, rhs) {
        case (.started, .started), (.loading, .loading):
            return true
        case (.finished(let lhsResult), .finished(let rhsResult)):
            switch (lhsResult, rhsResult) {
            case (.success(let lhsBool), .success(let rhsBool)):
                return lhsBool == rhsBool
            case (.failure, .failure):
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
}

