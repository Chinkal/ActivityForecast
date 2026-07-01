import Foundation

struct GeocodingRepository: GeocodingRepositoryProtocol {
    private let client: OpenMeteoGeocodingClient

    init(httpClient: HTTPClientProtocol) {
        self.client = OpenMeteoGeocodingClient(client: httpClient)
    }

    func searchCities(matching query: String) async throws -> [City] {
        let results = try await client.search(name: query)
        return results.map { $0.toDomain() }
    }
}
