---
title: API Reference
nav_order: 6
---

# API Contracts & BLoC Reference

Technical reference for domain entities, service interfaces, events, and states across the application.

---

## 1. `SearchCriteria` Entity

```dart
class SearchCriteria {
  final String? origin;
  final String? destination;
  final TravelDatePreference? datePreference;
  final String? originalDateExpression;
  final double? maxPrice;
  final int? maxDuration;
  final bool? directOnly;
  final SortPreference sortPreference;
}
```

---

## 2. `SortPreference` Enum

| Enum Value | Description | Trigger Expressions |
|:---|:---|:---|
| `SortPreference.cheapest` | Sorts flights by price ascending | `"cheapest"`, `"lowest fare"` |
| `SortPreference.expensive` | Sorts flights by price descending | `"expensive"`, `"premium"`, `"costliest"` |
| `SortPreference.fastest` | Sorts flights by total duration ascending | `"fastest"`, `"lesser layover"`, `"shorter duration"` |
| `SortPreference.longest` | Sorts flights by total duration descending | `"longest"`, `"more layover"`, `"longer duration"` |
| `SortPreference.earliest` | Sorts flights by departure time ascending | `"earliest"`, `"morning flight"` |
| `SortPreference.latest` | Sorts flights by departure time descending | `"latest"`, `"night flight"` |

---

## 3. `VoiceChatBloc` Events

- `InitVoiceChatEvent`: Initializes speech recognition and speaks welcome prompt.
- `StartListeningEvent`: Triggers audio recording & microphone listener.
- `StopListeningEvent`: Stops recording and dispatches transcribed text to AI.
- `SendTextMessageEvent(text)`: Sends text input directly to AI service.
- `SetGeminiApiKeyEvent(apiKey)`: Updates active Gemini API key in service locator.
