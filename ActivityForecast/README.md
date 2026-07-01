# Activity Forecast

Native iOS app that lets you search for a city and see a ranked list of activities suitable for that location over the next 7 days, based on Open-Meteo weather forecast data.

## Features

- City search via Open-Meteo Geocoding API
- 7-day daily weather forecast via Open-Meteo Forecast API
- Ranked activities: Skiing, Surfing, Outdoor Sightseeing, Indoor Sightseeing
- Debounced search with explicit loading, empty, and error states
- Unit tests for ranking logic and search ViewModel

## Architecture

The app uses **SwiftUI + MVVM** with a lightweight layered architecture:

```
Presentation (Views + ViewModels)
        ↓
Domain (Models, Protocols, ActivityRankingService)
        ↓
Data (API Clients, DTOs, Repositories)
```

### Layer responsibilities

| Layer | Role |
|-------|------|
| **Presentation** | SwiftUI views, `@Observable` ViewModels, explicit state enums |
| **Domain** | Business models, repository protocols, pure ranking logic |
| **Data** | HTTP client, Open-Meteo API clients, DTO decoding, repository implementations |

### Dependency injection

Dependencies are wired in `ActivityForecastApp` (composition root) and passed down as protocols (`GeocodingRepositoryProtocol`, `WeatherRepositoryProtocol`). This keeps ViewModels testable with mock repositories.

### Data flow

1. User types a city name → `CitySearchViewModel` debounces and calls `GeocodingRepository`
2. User selects a city → navigates to `ActivityRankingView`
3. `ActivityRankingViewModel` fetches 7-day forecast → `ActivityRankingService.rank()` → UI displays ranked list

## APIs used

### Geocoding
```
GET https://geocoding-api.open-meteo.com/v1/search?name={query}&count=10&language=en
```

### Forecast
```
GET https://api.open-meteo.com/v1/forecast
  ?latitude={lat}&longitude={lon}&timezone={tz}&forecast_days=7
  &daily=temperature_2m_max,temperature_2m_min,precipitation_sum,
         snowfall_sum,wind_speed_10m_max,weather_code
```

No API key required for non-commercial use.

## Weather assumptions

| Field | Why |
|-------|-----|
| **Daily aggregates** | Simpler and appropriate for "suitability over 7 days" vs hourly detail |
| **`temperature_2m_max/min`** | Comfort range for outdoor/indoor; cold threshold for skiing |
| **`precipitation_sum`** | Penalizes outdoor activities on wet days; boosts indoor |
| **`snowfall_sum`** | Primary signal for skiing suitability |
| **`wind_speed_10m_max`** | Proxy for surfing — Open-Meteo free tier has no wave height data |
| **`weather_code`** | WMO codes for rain, storms, fog, and clear skies |

The city's `timezone` from geocoding is passed to the forecast API so daily buckets align with local days.

## Ranking algorithm

Each activity is scored **per day** (0–100), then **averaged** across the forecast period. Activities are sorted by average score descending.

| Activity | Good conditions | Penalties |
|----------|-----------------|-----------|
| **Skiing** | Cold (`tempMax ≤ 2°C`), snowfall | Warm days, rain without snow |
| **Surfing** | Wind 15–35 km/h | Calm wind (<8), storms, heavy rain |
| **Outdoor sightseeing** | Mild temps (5–25°C), dry, clear skies | Extreme temps, rain/storms |
| **Indoor sightseeing** | Rain, cold, storms (inverse of outdoor) | Sunny mild days; heavy snow (ski weather) |

A day counts as "suitable" in the summary if its score is ≥ 60.

## Trade-offs (3–4 hour scope)

- No persistence, favorites, or offline cache
- No map UI or per-day expandable breakdown
- Surfing scored from wind speed only (no marine/wave API)
- Minimal visual polish — functional list UI with loading/error states
- Swift Testing framework used instead of XCTest for modern test syntax

## Requirements

- Xcode 26+
- iOS 26.2+ deployment target
- Internet connection for API calls

## How to run

1. Open `ActivityForecast.xcodeproj` in Xcode
2. Select an iOS Simulator
3. Press **Cmd+R**

## How to test

Press **Cmd+U** in Xcode, or from the command line:

```bash
xcodebuild -scheme ActivityForecast \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test
```

### Test coverage

- **`ActivityRankingServiceTests`** — snowy week → skiing first; rainy week → indoor first; windy week → surfing competitive; mild clear week → outdoor first
- **`CitySearchViewModelTests`** — short query skipped, success/empty/failure states with mock repository

## Project structure

```
ActivityForecast/
├── App/                    # App entry + DI
├── Domain/
│   ├── Models/
│   ├── Protocols/
│   └── Services/           # ActivityRankingService
├── Data/
│   ├── Networking/
│   ├── API/
│   └── Repositories/
└── Presentation/
    ├── Search/
    └── Activities/

ActivityForecastTests/
├── Mocks/
├── ActivityRankingServiceTests.swift
└── CitySearchViewModelTests.swift
```
