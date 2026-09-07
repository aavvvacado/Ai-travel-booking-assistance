---
title: API Reference & System Contracts
nav_order: 10
---

# 📖 API Reference & System Contracts

This document provides technical contract specifications for all domain entities, BLoC events, states, sort enums, and failure types across the application.

---

## 1. Core Domain Entities

### `SearchCriteria` Entity

```dart
class SearchCriteria extends Equatable {
  final String? origin;
  final String? destination;
  final TravelDatePreference? datePreference;
  final String? originalDateExpression;
  final double? maxPrice;
  final int? maxDuration;
  final bool? directOnly;
  final SortPreference sortPreference;

  SearchCriteria copyWith({ ... });
}
```

---

### `Flight` Entity

```dart
class Flight extends Equatable {
  final String id;
  final String flightNumber;
  final String airline;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final int durationMinutes;
  final List<String> layovers;
  final bool isDirect;
  final List<String> badges;
}
```

---

### `Booking` Entity

```dart
class Booking extends Equatable {
  final String bookingId;
  final Flight flight;
  final PassengerDetails passengerDetails;
  final String pnrReference; // 6-character code e.g. "PNR-9X8F21"
  final DateTime bookingDate;
  final String status; // "CONFIRMED" | "CANCELLED"
}
```

---

## 2. Enums & Value Contracts

### `SortPreference` Enum

| Enum Value | Sorting Behavior | Natural Language Triggers |
|:---|:---|:---|
| `SortPreference.cheapest` | Price Ascending | `"cheapest"`, `"lowest fare"`, `"under 25k"` |
| `SortPreference.expensive` | Price Descending | `"expensive"`, `"premium"`, `"costliest"` |
| `SortPreference.fastest` | Duration Ascending (Shortest first) | `"fastest"`, `"lesser layover"`, `"shorter duration"` |
| `SortPreference.longest` | Duration Descending (Longest first) | `"longest"`, `"more layover"`, `"longer duration"` |
| `SortPreference.earliest` | Departure Time Ascending | `"earliest"`, `"morning flight"` |
| `SortPreference.latest` | Departure Time Descending | `"latest"`, `"night flight"` |
| `SortPreference.none` | Default dataset order | No preference specified |

---

### `AiAction` Enum

| Enum Value | System Behavior |
|:---|:---|
| `AiAction.greeting` | Speaks welcome prompt and offers assistance. |
| `AiAction.askClarification` | Asks user for missing parameters (e.g. destination). |
| `AiAction.searchFlights` | Executes flight search filter pipeline and updates UI. |
| `AiAction.confirmBooking` | Triggers booking workflow for selected flight. |
| `AiAction.cancelBooking` | Cancels pending or active booking. |

---

## 3. BLoC Contracts (`VoiceChatBloc` & `BookingBloc`)

### `VoiceChatBloc` Events & States

- **Events**: `InitVoiceChatEvent`, `StartListeningEvent`, `StopListeningEvent`, `SendTextMessageEvent(text)`, `SetGeminiApiKeyEvent(apiKey)`, `ClearCriteriaEvent`.
- **State**: `VoiceChatState(messages, isListening, isThinking, partialSpeechText, searchCriteria, matchingFlights, smartBadges, activeApiKey)`.

### `BookingBloc` Events & States

- **Events**: `SelectFlightEvent(flight)`, `ConfirmBookingEvent(passengerDetails)`, `CancelBookingEvent`.
- **States**: `BookingInitial`, `BookingInProgress(selectedFlight)`, `BookingConfirmedState(booking)`, `BookingError(message)`.
