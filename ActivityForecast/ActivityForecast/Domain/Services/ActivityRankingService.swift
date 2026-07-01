import Foundation

struct ActivityRankingService {
    private let suitabilityThreshold = 60.0

    func rank(weather: [DailyWeather]) -> [RankedActivity] {
        guard !weather.isEmpty else {
            return Activity.allCases.enumerated().map { index, activity in
                RankedActivity(
                    activity: activity,
                    score: 0,
                    summary: "No forecast data available",
                    rank: index + 1
                )
            }
        }

        let scored = Activity.allCases.map { activity -> RankedActivity in
            let dayScores = weather.map { score(day: $0, for: activity) }
            let averageScore = dayScores.reduce(0, +) / Double(dayScores.count)
            let suitableDays = dayScores.filter { $0 >= suitabilityThreshold }.count
            let summary = "Suitable \(suitableDays) of \(weather.count) days"

            return RankedActivity(
                activity: activity,
                score: averageScore,
                summary: summary,
                rank: 0
            )
        }

        let sorted = scored.sorted { $0.score > $1.score }
        return sorted.enumerated().map { index, item in
            RankedActivity(
                activity: item.activity,
                score: item.score,
                summary: item.summary,
                rank: index + 1
            )
        }
    }

    func score(day: DailyWeather, for activity: Activity) -> Double {
        switch activity {
        case .skiing:
            return skiingScore(for: day)
        case .surfing:
            return surfingScore(for: day)
        case .outdoorSightseeing:
            return outdoorSightseeingScore(for: day)
        case .indoorSightseeing:
            return indoorSightseeingScore(for: day)
        }
    }

    private func skiingScore(for day: DailyWeather) -> Double {
        let coldScore = clamp(map(day.tempMax, from: (-10, 2), to: (100, 40)))
        let snowScore = clamp(min(day.snowfallCM * 15, 100))
        var score = coldScore * 0.5 + snowScore * 0.5

        if day.precipitationMM > 5 && day.snowfallCM < 1 {
            score -= 30
        }
        if day.tempMax > 5 {
            score -= 40
        }

        return clamp(score)
    }

    private func surfingScore(for day: DailyWeather) -> Double {
        let windScore: Double
        if day.maxWindKmh < 8 {
            windScore = 10
        } else if day.maxWindKmh < 15 {
            windScore = clamp(map(day.maxWindKmh, from: (8, 15), to: (30, 70)))
        } else if day.maxWindKmh <= 35 {
            windScore = clamp(map(day.maxWindKmh, from: (15, 35), to: (70, 100)))
        } else if day.maxWindKmh <= 45 {
            windScore = clamp(map(day.maxWindKmh, from: (35, 45), to: (100, 50)))
        } else {
            windScore = 20
        }

        var score = windScore

        if day.precipitationMM > 5 {
            score -= 25
        }
        if isStorm(code: day.weatherCode) {
            score -= 35
        }

        return clamp(score)
    }

    private func outdoorSightseeingScore(for day: DailyWeather) -> Double {
        let tempScore = clamp(map(day.tempMax, from: (5, 25), to: (20, 100)))
        let dryScore = day.precipitationMM < 1 ? 100.0 : clamp(100 - day.precipitationMM * 10)
        let skyScore = clearSkyScore(for: day.weatherCode)

        var score = tempScore * 0.35 + dryScore * 0.35 + skyScore * 0.3

        if day.tempMax < 0 || day.tempMax > 32 {
            score -= 25
        }
        if isRainOrStorm(code: day.weatherCode) {
            score -= 30
        }

        return clamp(score)
    }

    private func indoorSightseeingScore(for day: DailyWeather) -> Double {
        let outdoorScore = outdoorSightseeingScore(for: day)
        var score = 100 - outdoorScore

        if day.precipitationMM > 3 {
            score += 15
        }
        if day.tempMax < 5 || day.tempMax > 30 {
            score += 15
        }
        if isRainOrStorm(code: day.weatherCode) {
            score += 20
        }
        if day.snowfallCM > 2 {
            score -= 35
        }

        return clamp(score)
    }

    private func clearSkyScore(for code: Int) -> Double {
        switch code {
        case 0: 100
        case 1, 2: 80
        case 3: 50
        case 45, 48: 30
        default: 20
        }
    }

    private func isRainOrStorm(code: Int) -> Bool {
        (51 ... 67).contains(code) || (80 ... 99).contains(code)
    }

    private func isStorm(code: Int) -> Bool {
        (95 ... 99).contains(code)
    }

    private func map(_ value: Double, from range: (Double, Double), to output: (Double, Double)) -> Double {
        let (inMin, inMax) = range
        let (outMin, outMax) = output
        guard inMax != inMin else { return outMin }
        let ratio = (value - inMin) / (inMax - inMin)
        return outMin + ratio * (outMax - outMin)
    }

    private func clamp(_ value: Double, min minValue: Double = 0, max maxValue: Double = 100) -> Double {
        Swift.min(Swift.max(value, minValue), maxValue)
    }
}
