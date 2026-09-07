---
title: Clean Architecture
nav_order: 2
---

# Clean Architecture & System Layers

The application is structured around **Feature-Driven Clean Architecture** with strict unidirectional state flow. This design pattern ensures that UI components remain completely independent of business logic and external API services.

---

## 🏗️ System Data Flow

```text
[User Voice / Text Input]
          │
          ▼
   [SttService / Speech] ──► Transcribes Audio to Text
          │
          ▼
   [VoiceChatBloc] ──► Emits Processing State & ChatGPT Loading Bubble
          │
          ▼
   [AiService (Interface)]
     ├──► [HybridAiServiceImpl] (Google Gemini 1.5 Flash Online LLM)
     └──► [LocalRuleAiServiceImpl] (Zero-Config Deterministic Rule Engine)
          │
          ▼
   [Parsed Intent Payload & SearchCriteria]
          │
          ▼
   [FlightSearchService] ──► Filters & Sorts 200+ Mock Dataset Flights
          │
          ▼
   [UI Render] ──► Dynamic Flight Cards, Badges, TTS Audio Output & Digital Ticket View
```

---

## 📦 Layer Breakdown

### 1. Presentation Layer (`lib/features/flight_booking/presentation/`)
- **`VoiceChatBloc`**: Manages conversational state, speech input, partial recognition text, AI responses, and typing/search loading bubbles.
- **`BookingBloc`**: Manages flight search results, passenger details, booking confirmation steps, and PNR ticket generation.
- **Widgets**: `FlightCard`, `ChatBubble`, `GptLoadingBubble`, `ActiveCriteriaBar`, `BookingFlowSheet`.

### 2. Domain Layer (`lib/features/flight_booking/domain/`)
- **`SearchCriteria`**: Immutable entity tracking origin, destination, date preferences, budget caps, direct-only flags, and sorting rules.
- **`DateResolver`**: Specialized domain component translating relative expressions into concrete `DateTime` ranges.
- **`FlightSearchService`**: Performs deterministic filter evaluations and smart badge generation.

### 3. Data Layer (`lib/features/flight_booking/data/`)
- **`FlightLocalDataSource`**: Mock database provider containing 200+ realistic flight mockups across BOM, DEL, DXB, SIN, LHR, JFK.
- **`BookingLocalDataSource`**: In-memory repository tracking confirmed passenger bookings and references.

### 4. Core Services Layer (`lib/core/`)
- **`ServiceLocator`**: Global dependency injection container using GetIt pattern.
- **`AiService`**: Abstract contract for prompt parsing services.
- **`SttService` & `TtsService`**: Audio recognition and playback wrappers.
