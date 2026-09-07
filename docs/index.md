---
layout: default
title: Overview & Specifications
nav_order: 1
description: "AI Travel Assistant - Voice & Chat Flight Search built with Flutter, Clean Architecture & Gemini 1.5 Flash LLM."
---

# AI Travel Booking Assistant

[![Repository](https://img.shields.io/badge/GitHub-aavvvacado%2FAi--travel--booking--assistance-indigo?style=for-the-badge&logo=github)](https://github.com/aavvvacado/Ai-travel-booking-assistance)
[![Live Docs](https://img.shields.io/badge/Live%20Docs-GitHub%20Pages-emerald?style=for-the-badge&logo=githubpages)](https://aavvvacado.github.io/Ai-travel-booking-assistance/)
[![Theme](https://img.shields.io/badge/Theme-Stygian%20Dark-black?style=for-the-badge)](https://aavvvacado.github.io/Ai-travel-booking-assistance/)

A production-grade voice & chat flight search and booking application built with Flutter, Clean Architecture, Google Gemini 1.5 Flash LLM, and a zero-config deterministic Local NLP Rule Engine fallback.

---

## 🚀 Key Features

{: .note }
> **Hybrid Intelligence Engine**: Works out-of-the-box with zero API key configuration via `LocalRuleAiServiceImpl` or online reasoning via `HybridAiServiceImpl` powered by Google Gemini 1.5 Flash.

- **🎙️ Conversational Voice & Text Interface**: Supports continuous Speech-to-Text (STT) and Text-to-Speech (TTS) audio output with ChatGPT-style thinking and search animation bubbles.
- **📅 Advanced Date & Layover Resolution**: Resolves complex temporal queries like *"next month 7"* (Oct 7, 2026 relative to reference date Sep 7, 2026), *"next weekend after the 12th"*, and bidirectional layover/duration preferences.
- **🏷️ Smart Badging & Filtering**: Automatically sorts and badges flights (*✓ Cheapest direct option*, *✓ Shortest journey*, *✓ Premium option*) based on explicit user constraints.
- **✈️ End-to-End Mock Booking**: Complete flight booking workflow generating digital tickets with unique PNR references.

---

## 🏗️ Architecture At A Glance

The project follows **Feature-Driven Clean Architecture** with strict layer separation:

```mermaid
graph TD
    subgraph Presentation Layer
        UI[Flutter UI Widgets]
        VCB[VoiceChatBloc]
        BB[BookingBloc]
    end

    subgraph Domain Layer
        SC[SearchCriteria Entity]
        FSS[FlightSearchService]
        DR[DateResolver]
    end

    subgraph Data & Core Services
        FDS[FlightLocalDataSource]
        AI[AiService Interface]
        Gemini[HybridAiServiceImpl]
        Local[LocalRuleAiServiceImpl]
    end

    UI --> VCB
    VCB --> AI
    AI <|-- Gemini
    AI <|-- Local
    VCB --> BB
    BB --> FSS
    FSS --> FDS
```

| Layer | Path | Description |
|:---|:---|:---|
| **Presentation** | `lib/features/flight_booking/presentation/` | Flutter UI Widgets, `VoiceChatBloc`, `BookingBloc` |
| **Domain** | `lib/features/flight_booking/domain/` | Pure Business Entities, `DateResolver`, `FlightSearchService` |
| **Data** | `lib/features/flight_booking/data/` | `FlightLocalDataSource` (200+ realistic flight mockups) |
| **Core** | `lib/core/` | `ServiceLocator` (GetIt pattern), `AiService`, STT/TTS abstractions |

---

## ⚡ Quick Usage Example

```dart
// Parse natural prompt deterministically
final result = await parseUserIntentUseCase(
  userPrompt: 'Fly from Mumbai to Dubai next month 7 with lesser layover.',
  currentCriteria: const SearchCriteria(),
);

result.fold(
  (aiResult) {
    print('Action: ${aiResult.action}'); // SEARCH_FLIGHTS
    print('Departure Date: ${aiResult.updatedCriteria.dateText}'); // 2026-10-07
    print('Sort Preference: ${aiResult.updatedCriteria.sortPreference}'); // FASTEST
    print('Matching Flights: ${aiResult.matchingFlights.length}');
  },
  (failure) => print('Error: ${failure.message}'),
);
```

---

## 📚 Documentation Navigation

- [🚀 Installation & Setup Guide](setup-guide.html)
- [🏗️ Clean Architecture & Design Patterns](architecture.html)
- [📅 NLP & Date Resolver Engine](nlp-date-engine.html)
- [🧠 Hybrid Gemini LLM Integration](gemini-hybrid-ai.html)
- [📖 API & BLoC Reference](api-reference.html)
- [🛠️ Troubleshooting & FAQ](troubleshooting.html)
