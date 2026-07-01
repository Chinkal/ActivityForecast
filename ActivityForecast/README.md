# Activity Forecast

## Project Overview

Activity Forecast is a native iOS application built with SwiftUI that allows users to search for a city and view a ranked list of activities based on the next 7 days of weather forecast.

The application uses the Open-Meteo Geocoding API to search for cities and the Open-Meteo Forecast API to retrieve weather data. Based on the forecast, it ranks the following activities:

- Skiing
- Surfing
- Outdoor Sightseeing
- Indoor Sightseeing

The primary focus of this project is clean architecture, maintainability, testability, and explicit state management.

---

## Platform & Technologies

- Swift 6
- SwiftUI
- iOS 26.2
- Async/Await
- Observation Framework (`@Observable`)
- XCTest
- No third-party libraries

---

## Architecture

The application follows a layered **MVVM + Clean Architecture** approach.

```
Presentation
      │
      ▼
   Domain
      │
      ▼
     Data
```

### Presentation
- SwiftUI Views
- ViewModels
- Navigation
- UI State Management

### Domain
- Business Models
- Repository Protocols
- ActivityRankingService

### Data
- API Clients
- DTOs
- Repository Implementations
- Networking

Dependency Injection is implemented using protocols, making ViewModels independent of concrete implementations and easy to test.

---

## API Usage

### Geocoding API

Used to search cities by name.

Returns:

- City name
- Coordinates
- Country
- Timezone

### Forecast API

Used to retrieve a 7-day weather forecast.

Weather fields used:

- Maximum Temperature
- Minimum Temperature
- Precipitation
- Snowfall
- Maximum Wind Speed
- Weather Code

The timezone returned by the Geocoding API is passed to the Forecast API to ensure accurate local forecasts.

---

## Activity Ranking Logic

Each forecast day is scored between **0–100** for every activity. The final activity score is calculated by averaging the scores across all available forecast days.

| Activity | Preferred Conditions |
|----------|----------------------|
| Skiing | Cold temperatures with snowfall |
| Surfing | Moderate wind with low rainfall |
| Outdoor Sightseeing | Mild temperature, dry weather and clear skies |
| Indoor Sightseeing | Rainy, cold or stormy weather |

Activities are sorted by score and displayed from highest to lowest recommendation.

### Assumptions

- Wind speed is used as a proxy for surfing suitability because Open-Meteo does not provide wave height data.
- Outdoor sightseeing uses weather codes together with temperature and precipitation since cloud cover is only available through the hourly API.
- Rankings are calculated using all available forecast days if fewer than seven are returned.

---

## Error Handling

The application handles:

- Invalid URLs
- Network failures
- HTTP errors
- JSON decoding failures
- Empty search results

Meaningful error messages are displayed to users, while empty search results are treated as a valid application state.

---

## Testing

The project includes unit tests for the core business logic and presentation layer.

### ActivityRankingServiceTests

- Snowy weather ranks skiing highest
- Rainy weather ranks indoor sightseeing highest
- Windy weather improves surfing ranking
- Empty weather data is handled safely

### CitySearchViewModelTests

- Short queries do not trigger API requests
- Successful searches return results
- Repository failures transition to the failure state

Mock repositories are used to isolate ViewModels from networking dependencies.

---

## Build & Run

### Requirements

- Xcode 26 or later
- iOS 26.2 SDK

### Run

1. Open the project in Xcode.
2. Select an iOS Simulator.
3. Press **⌘R** to build and run.

### Run Tests

Press **⌘U** in Xcode

or

```bash
xcodebuild test
```

---

## Production Readiness

With additional development time, the application could be enhanced with:

- Offline caching
- Retry strategies for network requests
- Accessibility improvements
- Localization
- UI and Snapshot tests
- Analytics and logging
- CI/CD pipeline

---

## AI Usage

Cursor and ChatGPT were used to assist with project scaffolding, boilerplate generation, and implementation suggestions.

All generated code was manually reviewed, validated, tested, and refined where necessary. Final architecture, business logic, and implementation decisions were verified by the author.

## Screenshots
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-07-01 at 15 22 00" src="https://github.com/user-attachments/assets/1c7b95d3-8197-4802-85b1-e158010644ca" />

<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-07-01 at 15 22 05" src="https://github.com/user-attachments/assets/a799b9f6-2386-45fd-8716-4d41add2ce59" />

