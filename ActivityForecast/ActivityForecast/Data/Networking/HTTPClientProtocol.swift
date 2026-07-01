import Foundation

protocol HTTPClientProtocol: Sendable {
    func data(from url: URL) async throws -> Data
}
