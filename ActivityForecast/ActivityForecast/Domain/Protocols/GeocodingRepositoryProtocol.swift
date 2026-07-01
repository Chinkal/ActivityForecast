import Foundation

protocol GeocodingRepositoryProtocol: Sendable {
    func searchCities(matching query: String) async throws -> [City]
}
