import Foundation

enum CitySearchState: Equatable {
    case idle
    case searching
    case results([City])
    case empty
    case failure(String)
}
