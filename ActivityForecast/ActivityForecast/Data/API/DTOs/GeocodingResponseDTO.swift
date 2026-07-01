import Foundation

struct GeocodingResponseDTO: Decodable {
    let results: [GeocodingResultDTO]?

    var cities: [GeocodingResultDTO] {
        results ?? []
    }
}

struct GeocodingResultDTO: Decodable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
    let admin1: String?
    let timezone: String
    let elevation: Double
}

extension GeocodingResultDTO {
    func toDomain() -> City {
        City(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            country: country,
            admin1: admin1,
            timezone: timezone,
            elevation: elevation
        )
    }
}
