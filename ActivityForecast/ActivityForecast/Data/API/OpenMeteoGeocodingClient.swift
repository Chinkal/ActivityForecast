import Foundation

struct OpenMeteoGeocodingClient: Sendable {
    private let client: HTTPClientProtocol
    private let baseURL = "https://geocoding-api.open-meteo.com/v1/search"

    init(client: HTTPClientProtocol) {
        self.client = client
    }

    func search(name: String, count: Int = 10) async throws -> [GeocodingResultDTO] {
        guard var components = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "count", value: String(count)),
            URLQueryItem(name: "language", value: "en")
        ]
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        let data = try await client.data(from: url)
        do {
            let response = try JSONDecoder().decode(GeocodingResponseDTO.self, from: data)
            return response.cities
        } catch {
            throw APIError.decoding(error.localizedDescription)
        }
    }
}
