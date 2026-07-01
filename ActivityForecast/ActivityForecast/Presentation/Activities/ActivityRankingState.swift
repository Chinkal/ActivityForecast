import Foundation

enum ActivityRankingState: Equatable {
    case idle
    case loading
    case loaded([RankedActivity])
    case failure(String)
}
