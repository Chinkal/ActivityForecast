import Foundation

struct ForecastResponseDTO: Decodable {
    let daily: DailyForecastDTO
}

struct DailyForecastDTO: Decodable {
    let time: [String]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let precipitationSum: [Double]
    let snowfallSum: [Double]
    let windSpeed10mMax: [Double]
    let weatherCode: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case precipitationSum = "precipitation_sum"
        case snowfallSum = "snowfall_sum"
        case windSpeed10mMax = "wind_speed_10m_max"
        case weatherCode = "weather_code"
    }

    func toDomain() -> [DailyWeather] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        return time.enumerated().compactMap { index, dateString in
            guard let date = formatter.date(from: dateString) else { return nil }
            return DailyWeather(
                date: date,
                tempMax: value(at: index, in: temperature2mMax),
                tempMin: value(at: index, in: temperature2mMin),
                precipitationMM: value(at: index, in: precipitationSum),
                snowfallCM: value(at: index, in: snowfallSum),
                maxWindKmh: value(at: index, in: windSpeed10mMax),
                weatherCode: Int(value(at: index, in: weatherCode.map(Double.init)))
            )
        }
    }

    private func value(at index: Int, in array: [Double]) -> Double {
        guard index < array.count else { return 0 }
        return array[index]
    }
}
