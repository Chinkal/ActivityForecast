import Foundation

enum APIError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding(String)
    case serverMessage(String)
    case noResults

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The request URL is invalid."
        case .invalidResponse:
            "The server returned an unexpected response."
        case .httpStatus(let code):
            "The server returned status code \(code)."
        case .decoding(let message):
            "Failed to read the response: \(message)"
        case .serverMessage(let message):
            message
        case .noResults:
            "No results found."
        }
    }
}

struct OpenMeteoErrorDTO: Decodable {
    let error: Bool
    let reason: String
}
