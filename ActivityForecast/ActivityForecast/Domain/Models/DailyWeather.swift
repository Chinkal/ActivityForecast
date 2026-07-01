import Foundation

struct DailyWeather: Equatable {
    let date: Date
    let tempMax: Double
    let tempMin: Double
    let precipitationMM: Double
    let snowfallCM: Double
    let maxWindKmh: Double
    let weatherCode: Int
}
