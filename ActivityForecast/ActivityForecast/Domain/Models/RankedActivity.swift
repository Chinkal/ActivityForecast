import Foundation

struct RankedActivity: Identifiable, Equatable {
    let activity: Activity
    let score: Double
    let summary: String
    let rank: Int

    var id: String { activity.id }
}
