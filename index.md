---
layout: docs
title: Overview & Specifications
nav_order: 1
---

# AI Travel Booking Assistant

A production-grade voice & chat flight search and booking application built with Flutter, Clean Architecture, Google Gemini 1.5 Flash LLM, and a zero-config deterministic Local NLP Rule Engine fallback.

---

## 🚀 Key Features

> **Hybrid Intelligence Engine**: Works out-of-the-box with zero API key configuration via `LocalRuleAiServiceImpl` or online reasoning via `HybridAiServiceImpl` powered by Google Gemini 1.5 Flash.

- **🎙️ Conversational Voice & Text Interface**: Supports continuous Speech-to-Text (STT) and Text-to-Speech (TTS) audio output with ChatGPT-style thinking and search animation bubbles.
- **📅 Advanced Date & Layover Resolution**: Resolves complex temporal queries like *"next month 7"* (Oct 7, 2026 relative to reference date Sep 7, 2026), *"next weekend after the 12th"*, and bidirectional layover/duration preferences.
- **🏷️ Smart Badging & Filtering**: Automatically sorts and badges flights (*✓ Cheapest direct option*, *✓ Shortest journey*, *✓ Premium option*) based on explicit user constraints.
- **✈️ End-to-End Mock Booking**: Complete flight booking workflow generating digital tickets with unique PNR references.

---

## ⚙️ Project & Environment Configuration

The application and documentation site are configured with the following technical specifications:

### 🌐 Documentation Site Config (`_config.yml`)

| Property | Value / Setting | Description |
|:---|:---|:---|
| **Theme** | `ksauraj/stygian` | Pure Jekyll remote theme rendering standard Markdown |
| **Markdown Engine** | `kramdown` (GFM) | GitHub Flavored Markdown with auto ID generation |
| **Highlighter** | `rouge` | Code block syntax highlighting without extra JS overhead |
| **Base URL** | `/Ai-travel-booking-assistance` | Base path for GitHub Pages deployment |
| **Default Layout** | `layout: docs` | Applies doc navigation sidebar across all collection items |

### 🛠️ Runtime & Environment Variables

| Variable / Parameter | Setting | Description |
|:---|:---|:---|
| `GEMINI_API_KEY` | System Env or UI Dialog | Key for Google Gemini 1.5 Flash LLM (`AIzaSy...` or `AQ...`) |
| `reference_date` | `2026-09-07` | Base anchor date for relative NLP date resolution |
| `FLUTTER_WEB_USE_SKIA` | `true` | Enables high-performance canvas rendering on web target |

### 📦 Application Dependencies (`pubspec.yaml`)

| Package | Version | Purpose |
|:---|:---|:---|
| **Flutter SDK** | `^3.8.1` / Dart `^3.3.0` | Core SDK platform constraints |
| `flutter_bloc` | `^8.1.3` | Unidirectional state management (VoiceChat & Booking BLoCs) |
| `google_generative_ai` | `^0.4.6` | Google Gemini 1.5 Flash official Dart SDK integration |
| `speech_to_text` | `^7.0.0` | Device microphone capture & continuous STT transcription |
| `flutter_tts` | `^4.2.0` | Text-to-speech audio synthesis for voice responses |
| `get_it` | `^7.6.7` | Service Locator dependency injection container |
| `equatable` | `^2.0.5` | Value equality comparison for BLoC states and entities |
| `intl` | `^0.19.0` | Date formatting and temporal parsing utilities |

---

## 🏗️ Architecture At A Glance

The project follows **Feature-Driven Clean Architecture** with strict layer separation and unidirectional state flow:

```mermaid
graph TD
    subgraph UI ["1. Presentation Layer (UI & BLoC)"]
        TAP["TravelAssistantPage"]
        VCB["VoiceChatBloc"]
        BB["BookingBloc"]
        GLB["GptLoadingBubble"]
        FC["FlightCard Widgets"]
    end

    subgraph Domain ["2. Domain Layer (Business Logic & Entities)"]
        PUC["ParseUserIntentUseCase"]
        FSS["FlightSearchService"]
        DR["DateResolver"]
        SC["SearchCriteria Entity"]
    end

    subgraph Core ["3. Core Services & Infrastructure"]
        AI["AiService Contract"]
        Gemini["HybridAiServiceImpl (Gemini LLM)"]
        Local["LocalRuleAiServiceImpl (NLP Engine)"]
        STT["SttService (Speech-to-Text)"]
        TTS["TtsService (Text-to-Speech)"]
        SL["ServiceLocator (GetIt)"]
    end

    subgraph Data ["4. Data Layer (Data Sources & Repos)"]
        FDS["FlightLocalDataSource (200+ Flights)"]
        BDS["BookingLocalDataSource (PNR Store)"]
        FR["FlightRepositoryImpl"]
        BR["BookingRepositoryImpl"]
    end

    TAP -->|User Voice / Text| VCB
    VCB -->|Dispatches Intent| PUC
    PUC -->|Parses via Interface| AI
    Gemini -.->|Online LLM| AI
    Local -.->|Deterministic Engine| AI
    AI -->|Parses Dates| DR
    PUC -->|Returns Updated Criteria| VCB
    VCB -->|Triggers Search| BB
    BB -->|Executes Filter & Sort| FSS
    FSS -->|Queries Dataset| FDS
    FSS -->|Emits Smart Badges| FC
    BB -->|Generates PNR Ticket| BDS
```

### Layer Responsibilities & Contracts

| Layer | Directory Path | Core Responsibilities & Key Exports |
|:---|:---|:---|
| **Presentation** | `lib/features/flight_booking/presentation/` | UI Pages (`TravelAssistantPage`, `TicketViewPage`), Dialogs (`BookingDialog`), Widgets (`GptLoadingBubble`, `FlightCard`), BLoCs (`VoiceChatBloc`, `BookingBloc`). |
| **Domain** | `lib/features/flight_booking/domain/` | Pure Dart Entities (`SearchCriteria`, `Flight`, `Booking`), Use Cases (`ParseUserIntentUseCase`, `SearchFlightsUseCase`), Domain Services (`DateResolver`, `FlightSearchService`). |
| **Data** | `lib/features/flight_booking/data/` | Models (`FlightModel`, `BookingModel`), Data Sources (`FlightLocalDataSource` with 200+ flight mockups, `BookingLocalDataSource`), Repository Implementations. |
| **Core** | `lib/core/` | Global Service Locator (`GetIt`), AI Contracts (`AiService`, `HybridAiServiceImpl`, `LocalRuleAiServiceImpl`), Hardware Wrappers (`SttService`, `TtsService`), Utilities (`DateParser`, `ReferenceGenerator`). |

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

## 📚 Complete Documentation Set

Explore the full technical documentation suite:

- [📄 Codebase File Index](Codebase-File-Index) — Exhaustive file-by-file code guide explaining every file in the project.
- [🏗️ Clean Architecture](Clean-Architecture) — Detailed explanation of layer separation, dependency inversion, and BLoC state flow.
- [📅 NLP & Date Resolver Engine](NLP-and-Date-Resolver) — Guide to date parsing rules, relative calculations (*"next month 7"*), and bidirectional layover sorting.
- [🧠 Hybrid Gemini LLM Integration](Hybrid-Gemini-LLM) — Online Google Gemini 1.5 Flash JSON schema enforcement and local fallback mechanics.
- [📖 API & BLoC Reference](API-Reference) — Comprehensive entity contracts, sort enums, events, and states reference.
- [🛠️ Installation & Setup Guide](Installation-Setup) — Workstation setup, API key options, and testing instructions.
- [❓ Troubleshooting & FAQ](Troubleshooting) — Solutions for common questions, microphone permissions, and edge cases.

