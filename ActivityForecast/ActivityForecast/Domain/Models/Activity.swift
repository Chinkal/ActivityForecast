import Foundation

enum Activity: String, CaseIterable, Identifiable, Equatable {
    case skiing
    case surfing
    case outdoorSightseeing
    case indoorSightseeing

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .skiing: "Skiing"
        case .surfing: "Surfing"
        case .outdoorSightseeing: "Outdoor Sightseeing"
        case .indoorSightseeing: "Indoor Sightseeing"
        }
    }
}
