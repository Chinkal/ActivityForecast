import Foundation

struct City: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
    let admin1: String?
    let timezone: String
    let elevation: Double

    var displaySubtitle: String {
        if let admin1, !admin1.isEmpty {
            return "\(admin1), \(country)"
        }
        return country
    }
}
