import Foundation

struct URLSessionHTTPClient: HTTPClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200 ... 299).contains(httpResponse.statusCode) else {
            if let serverError = try? JSONDecoder().decode(OpenMeteoErrorDTO.self, from: data) {
                throw APIError.serverMessage(serverError.reason)
            }
            throw APIError.httpStatus(httpResponse.statusCode)
        }
        return data
    }
}
