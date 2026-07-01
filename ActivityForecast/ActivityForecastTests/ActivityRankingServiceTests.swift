import Foundation
import Testing
@testable import ActivityForecast

struct ActivityRankingServiceTests {
    private let service = ActivityRankingService()
    private let calendar = Calendar(identifier: .gregorian)

    private func makeDay(
        dayOffset: Int,
        tempMax: Double,
        tempMin: Double = 0,
        precipitation: Double = 0,
        snowfall: Double = 0,
        wind: Double = 10,
        weatherCode: Int = 0
    ) -> DailyWeather {
        DailyWeather(
            date: calendar.date(byAdding: .day, value: dayOffset, to: Date(timeIntervalSince1970: 0))!,
            tempMax: tempMax,
            tempMin: tempMin,
            precipitationMM: precipitation,
            snowfallCM: snowfall,
            maxWindKmh: wind,
            weatherCode: weatherCode
        )
    }

    @Test func snowyColdWeekRanksSkiingFirst() {
        let weather = (0 ..< 7).map { offset in
            makeDay(dayOffset: offset, tempMax: -2, tempMin: -8, snowfall: 5, wind: 12)
        }

        let ranked = service.rank(weather: weather)

        #expect(ranked.first?.activity == .skiing)
        #expect(ranked.first?.rank == 1)
    }

    @Test func rainyWeekRanksIndoorFirst() {
        let weather = (0 ..< 7).map { offset in
            makeDay(dayOffset: offset, tempMax: 14, precipitation: 10, weatherCode: 63)
        }

        let ranked = service.rank(weather: weather)

        #expect(ranked.first?.activity == .indoorSightseeing)
    }

    @Test func windyDryWeekRanksSurfingCompetitively() {
        let weather = (0 ..< 7).map { offset in
            makeDay(dayOffset: offset, tempMax: 18, wind: 25, weatherCode: 1)
        }

        let ranked = service.rank(weather: weather)

        #expect(ranked.contains { $0.activity == .surfing && $0.rank <= 2 })
    }

    @Test func mildClearWeekRanksOutdoorSightseeingHighly() {
        let weather = (0 ..< 7).map { offset in
            makeDay(dayOffset: offset, tempMax: 20, tempMin: 12, wind: 5, weatherCode: 0)
        }

        let ranked = service.rank(weather: weather)

        #expect(ranked.first?.activity == .outdoorSightseeing)
    }

    @Test func emptyWeatherReturnsZeroScores() {
        let ranked = service.rank(weather: [])

        #expect(ranked.count == 4)
        #expect(ranked.allSatisfy { $0.score == 0 })
    }

    @Test func scoresAreWithinValidRange() {
        let weather = [
            makeDay(dayOffset: 0, tempMax: 22, precipitation: 2, wind: 20, weatherCode: 2),
            makeDay(dayOffset: 1, tempMax: -5, snowfall: 8, wind: 15, weatherCode: 71)
        ]

        for activity in Activity.allCases {
            for day in weather {
                let score = service.score(day: day, for: activity)
                #expect(score >= 0)
                #expect(score <= 100)
            }
        }
    }
}
