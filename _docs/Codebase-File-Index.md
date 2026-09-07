---
title: Codebase File Index
nav_order: 3
---

# Codebase File Index & Exhaustive Component Guide

This document provides a detailed, file-by-file breakdown of every source file, domain entity, BLoC state container, utility module, widget, and configuration file in the **AI Travel Booking Assistant** repository.

---

## Quick Navigation by Architecture Layer

- [1. Application Entry & Testing (`lib/main.dart`, `test/`)](#1-application-entry--testing-libmaindart-test)
- [2. Core Infrastructure & Services (`lib/core/`)](#2-core-infrastructure--services-libcore)
- [3. Domain Layer (`lib/features/flight_booking/domain/`)](#3-domain-layer-libfeaturesflight_bookingdomain)
- [4. Data Layer (`lib/features/flight_booking/data/`)](#4-data-layer-libfeaturesflight_bookingdata)
- [5. Presentation Layer — BLoCs & State Management](#5-presentation-layer--blocs--state-management)
- [6. Presentation Layer — Pages & UI Views](#6-presentation-layer--pages--ui-views)
- [7. Presentation Layer — UI Widgets & Components](#7-presentation-layer--ui-widgets--components)
- [8. Documentation & Project Configuration](#8-documentation--project-configuration)

---

## 1. Application Entry & Testing (`lib/main.dart`, `test/`)

### `lib/main.dart`
- **Path**: `lib/main.dart`
- **Purpose**: Root application entry point.
- **Key Responsibilities**:
  - Initializes `ServiceLocator.setup()` asynchronously before widget tree mounting.
  - Configures global `MaterialApp` with `AppTheme.darkTheme`.
  - Injects `VoiceChatBloc` and `BookingBloc` at the root widget level using `MultiBlocProvider`.
  - Sets `TravelAssistantPage` as the primary home screen widget.

### `test/widget_test.dart`
- **Path**: `test/widget_test.dart`
- **Purpose**: Complete automated unit test suite (14 test cases).
- **Key Responsibilities**:
  - Tests `DateResolver` for exact dates (`"tomorrow"`), relative offsets (`"next month 7"` -> `2026-10-07`), and weekend rules (`"next weekend after the 12th"`).
  - Tests `LocalRuleAiServiceImpl` for intent parsing, city extraction, budget caps, direct-only flags.
  - Tests bidirectional sorting (`SortPreference.fastest` for *"lesser layover"*, `SortPreference.longest` for *"more duration"*).
  - Verifies date correction workflows when users specify updated dates in follow-up prompts.

---

## 2. Core Infrastructure & Services (`lib/core/`)

### `lib/core/constants/api_constants.dart`
- **Path**: `lib/core/constants/api_constants.dart`
- **Purpose**: Global constants and AI system prompt definitions.
- **Key Responsibilities**:
  - Holds `geminiModelName = 'gemini-1.5-flash'`.
  - Defines `systemPrompt` enforcing structured JSON responses from Gemini LLM.
  - Defines schema contract for `action`, `spoken_response`, `parameters` (origin, destination, departure_date, max_price, max_duration, direct_only, sort_preference).

### `lib/core/errors/failures.dart`
- **Path**: `lib/core/errors/failures.dart`
- **Purpose**: Functional error handling class hierarchy.
- **Key Responsibilities**:
  - `Failure`: Base abstract class containing error `message`.
  - `ServerFailure`: Network or Gemini LLM service communication failure.
  - `CacheFailure`: Local data storage access failure.
  - `NlpParsingFailure`: NLP pattern recognition failure wrapper.

### `lib/core/errors/result.dart`
- **Path**: `lib/core/errors/result.dart`
- **Purpose**: Sealed functional result wrapper (`Result<T>`).
- **Key Responsibilities**:
  - Eliminates unhandled exceptions by wrapping responses in either `Success(data)` or `Error(failure)`.
  - Provides `fold(onSuccess, onError)` method for pattern matching.

### `lib/core/services/ai_service.dart`
- **Path**: `lib/core/services/ai_service.dart`
- **Purpose**: Abstract AI parsing contract & concrete implementations.
- **Key Responsibilities**:
  - `AiService`: Abstract interface defining `parseUserIntent(userPrompt, currentCriteria)`.
  - `LocalRuleAiServiceImpl`: Zero-config deterministic rule engine using regular expressions, keyword tokenization, and `DateResolver`.
  - `HybridAiServiceImpl`: Google Gemini 1.5 Flash LLM implementation with automatic JSON deserialization and instant fallback to `LocalRuleAiServiceImpl` on error or missing key.

### `lib/core/services/service_locator.dart`
- **Path**: `lib/core/services/service_locator.dart`
- **Purpose**: Dependency Injection container using GetIt.
- **Key Responsibilities**:
  - `ServiceLocator.setup()`: Registers singletons for `SttService`, `TtsService`, `FlightLocalDataSource`, `BookingLocalDataSource`.
  - Registers factory constructors for `VoiceChatBloc`, `BookingBloc`, `ParseUserIntentUseCase`, `SearchFlightsUseCase`, `ConfirmBookingUseCase`, `CancelBookingUseCase`.

### `lib/core/services/stt_service.dart`
- **Path**: `lib/core/services/stt_service.dart`
- **Purpose**: Hardware Speech-to-Text wrapper around `speech_to_text`.
- **Key Responsibilities**:
  - Manages microphone permission requests.
  - Starts continuous audio listening and passes partial transcribed text back via callbacks.
  - Handles sound level listeners for audio wave visualization.

### `lib/core/services/tts_service.dart`
- **Path**: `lib/core/services/tts_service.dart`
- **Purpose**: Hardware Text-to-Speech wrapper around `flutter_tts`.
- **Key Responsibilities**:
  - Synthesizes vocal assistant responses.
  - Supports speech rate, pitch control, and language selection (`en-US`).
  - Provides `stop()` to interrupt active speech playback.

### `lib/core/theme/app_colors.dart`
- **Path**: `lib/core/theme/app_colors.dart`
- **Purpose**: Color palette definition for dark theme & glassmorphism.
- **Key Responsibilities**:
  - `primary`: Deep indigo/purple gradient primary color (`#6366F1`).
  - `background`: Dark slate background (`#0F172A`).
  - `surface` & `cardBackground`: Translucent glassmorphism surfaces (`#1E293B`).
  - Badge colors: Green for cheapest (`#22C55E`), Cyan for shortest duration (`#06B6D4`), Amber for premium (`#F59E0B`).

### `lib/core/theme/app_theme.dart`
- **Path**: `lib/core/theme/app_theme.dart`
- **Purpose**: ThemeData configuration builder.
- **Key Responsibilities**:
  - Configures dark theme Material 3 typography, card elevation, chip themes, and input decorations.

### `lib/core/utils/date_parser.dart`
- **Path**: `lib/core/utils/date_parser.dart`
- **Purpose**: ISO string and user date parsing utilities.
- **Key Responsibilities**:
  - Parses `YYYY-MM-DD` string inputs into `DateTime` objects.
  - Formats `DateTime` instances into readable strings (`"Wed, Oct 7, 2026"`).

### `lib/core/utils/date_resolver.dart`
- **Path**: `lib/core/utils/date_resolver.dart`
- **Purpose**: Core NLP temporal engine.
- **Key Responsibilities**:
  - Anchors relative calculations to `referenceDate = DateTime(2026, 9, 7)`.
  - Resolves exact dates: `"tomorrow"` -> `2026-09-08`, `"next month 7"` -> `2026-10-07`.
  - Resolves date ranges: `"next weekend"` -> `Sep 12 - Sep 13`, `"next week"` -> `Sep 14 - Sep 20`.
  - Resolves offset expressions: `"next weekend after the 12th"` -> `Sep 19 - Sep 20`.

### `lib/core/utils/reference_generator.dart`
- **Path**: `lib/core/utils/reference_generator.dart`
- **Purpose**: Booking reference generator.
- **Key Responsibilities**:
  - Generates 6-character uppercase alphanumeric PNR codes (e.g. `PNR-K9X4M2`).

---

## 3. Domain Layer (`lib/features/flight_booking/domain/`)

### `lib/features/flight_booking/domain/entities/booking.dart`
- **Path**: `lib/features/flight_booking/domain/entities/booking.dart`
- **Purpose**: Domain entity for confirmed passenger bookings.
- **Key Responsibilities**:
  - Encapsulates `bookingId`, `flight`, `passengerDetails`, `pnrReference`, `bookingDate`, and status (`CONFIRMED`, `CANCELLED`).

### `lib/features/flight_booking/domain/entities/booking_confirmation.dart`
- **Path**: `lib/features/flight_booking/domain/entities/booking_confirmation.dart`
- **Purpose**: Confirmation payload object returned after ticket issuance.

### `lib/features/flight_booking/domain/entities/chat_message.dart`
- **Path**: `lib/features/flight_booking/domain/entities/chat_message.dart`
- **Purpose**: Chat timeline message object.
- **Key Responsibilities**:
  - Holds `id`, `text`, `sender` (`USER` vs `ASSISTANT`), `timestamp`, and optional payload list of `matchingFlights`.

### `lib/features/flight_booking/domain/entities/flight.dart`
- **Path**: `lib/features/flight_booking/domain/entities/flight.dart`
- **Purpose**: Flight model entity.
- **Key Responsibilities**:
  - Encapsulates `id`, `flightNumber`, `airline`, `origin`, `destination`, `departureTime`, `arrivalTime`, `price`, `durationMinutes`, `layovers`, `isDirect`, `badges`.

### `lib/features/flight_booking/domain/entities/passenger_details.dart`
- **Path**: `lib/features/flight_booking/domain/entities/passenger_details.dart`
- **Purpose**: Immutable entity holding passenger contact and ID information.

### `lib/features/flight_booking/domain/entities/search_criteria.dart`
- **Path**: `lib/features/flight_booking/domain/entities/search_criteria.dart`
- **Purpose**: Central state entity tracking flight search query parameters.
- **Key Responsibilities**:
  - Tracks `origin`, `destination`, `datePreference`, `maxPrice`, `maxDuration`, `directOnly`, and `sortPreference`.

### `lib/features/flight_booking/domain/entities/travel_date_preference.dart`
- **Path**: `lib/features/flight_booking/domain/entities/travel_date_preference.dart`
- **Purpose**: Sealed class hierarchy for date requirements.
- **Key Responsibilities**:
  - Subclasses: `ExactDatePreference`, `DateRangePreference`, `FlexibleDatePreference`.

### `lib/features/flight_booking/domain/repositories/booking_repository.dart`
- **Path**: `lib/features/flight_booking/domain/repositories/booking_repository.dart`
- **Purpose**: Abstract repository contract for booking management.

### `lib/features/flight_booking/domain/repositories/flight_repository.dart`
- **Path**: `lib/features/flight_booking/domain/repositories/flight_repository.dart`
- **Purpose**: Abstract repository contract for flight search.

### `lib/features/flight_booking/domain/services/flight_search_service.dart`
- **Path**: `lib/features/flight_booking/domain/services/flight_search_service.dart`
- **Purpose**: Flight sorting, filtering, and smart badge calculation service.
- **Key Responsibilities**:
  - Filters 200+ flights against origin, destination, price cap, layovers, and date preferences.
  - Sorts flights by price (`cheapest`, `expensive`), duration (`fastest`, `longest`), or schedule (`earliest`, `latest`).
  - Attaches smart badges (*✓ Cheapest direct option*, *✓ Shortest journey*).

### `lib/features/flight_booking/domain/services/mock_booking_service.dart`
- **Path**: `lib/features/flight_booking/domain/services/mock_booking_service.dart`
- **Purpose**: Mock ticket generation service.

### `lib/features/flight_booking/domain/usecases/cancel_booking_usecase.dart`
- **Path**: `lib/features/flight_booking/domain/usecases/cancel_booking_usecase.dart`
- **Purpose**: Use case to process booking cancellations.

### `lib/features/flight_booking/domain/usecases/confirm_booking_usecase.dart`
- **Path**: `lib/features/flight_booking/domain/usecases/confirm_booking_usecase.dart`
- **Purpose**: Use case to confirm passenger details and issue PNR ticket.

### `lib/features/flight_booking/domain/usecases/parse_user_intent_usecase.dart`
- **Path**: `lib/features/flight_booking/domain/usecases/parse_user_intent_usecase.dart`
- **Purpose**: Use case bridging user prompts to `AiService` intent extraction.

### `lib/features/flight_booking/domain/usecases/search_flights_usecase.dart`
- **Path**: `lib/features/flight_booking/domain/usecases/search_flights_usecase.dart`
- **Purpose**: Use case executing flight searches via `FlightRepository`.

---

## 4. Data Layer (`lib/features/flight_booking/data/`)

### `lib/features/flight_booking/data/datasources/booking_local_datasource.dart`
- **Path**: `lib/features/flight_booking/data/datasources/booking_local_datasource.dart`
- **Purpose**: In-memory booking store for confirmed tickets.

### `lib/features/flight_booking/data/datasources/flight_local_datasource.dart`
- **Path**: `lib/features/flight_booking/data/datasources/flight_local_datasource.dart`
- **Purpose**: Dataset of 200+ realistic mock flights across BOM, DEL, DXB, SIN, LHR, JFK with varied prices, departure times, layovers, and seat availability.

### `lib/features/flight_booking/data/models/booking_model.dart`
- **Path**: `lib/features/flight_booking/data/models/booking_model.dart`
- **Purpose**: Data model handling JSON conversion for `Booking`.

### `lib/features/flight_booking/data/models/flight_model.dart`
- **Path**: `lib/features/flight_booking/data/models/flight_model.dart`
- **Purpose**: Data model handling JSON conversion for `Flight`.

### `lib/features/flight_booking/data/repositories/booking_repository_impl.dart`
- **Path**: `lib/features/flight_booking/data/repositories/booking_repository_impl.dart`
- **Purpose**: Concrete `BookingRepository` implementation.

### `lib/features/flight_booking/data/repositories/flight_repository_impl.dart`
- **Path**: `lib/features/flight_booking/data/repositories/flight_repository_impl.dart`
- **Purpose**: Concrete `FlightRepository` implementation.

---

## 5. Presentation Layer — BLoCs & State Management

### `lib/features/flight_booking/presentation/bloc/booking_bloc.dart`
- **Path**: `lib/features/flight_booking/presentation/bloc/booking_bloc.dart`
- **Purpose**: BLoC managing passenger form input and booking workflow.

### `lib/features/flight_booking/presentation/bloc/booking_event.dart`
- **Path**: `lib/features/flight_booking/presentation/bloc/booking_event.dart`
- **Purpose**: Events for `BookingBloc` (`SelectFlightEvent`, `ConfirmBookingEvent`, `CancelBookingEvent`).

### `lib/features/flight_booking/presentation/bloc/booking_state.dart`
- **Path**: `lib/features/flight_booking/presentation/bloc/booking_state.dart`
- **Purpose**: States for `BookingBloc` (`BookingInitial`, `BookingInProgress`, `BookingConfirmedState`, `BookingError`).

### `lib/features/flight_booking/presentation/bloc/voice_chat_bloc.dart`
- **Path**: `lib/features/flight_booking/presentation/bloc/voice_chat_bloc.dart`
- **Purpose**: Central voice and chat conversation BLoC. Handles prompt processing, speech listening state, thinking loading bubble, active search criteria, and TTS playback.

### `lib/features/flight_booking/presentation/bloc/voice_chat_event.dart`
- **Path**: `lib/features/flight_booking/presentation/bloc/voice_chat_event.dart`
- **Purpose**: Events for `VoiceChatBloc` (`InitVoiceChatEvent`, `StartListeningEvent`, `StopListeningEvent`, `SendTextMessageEvent`, `SetGeminiApiKeyEvent`).

### `lib/features/flight_booking/presentation/bloc/voice_chat_state.dart`
- **Path**: `lib/features/flight_booking/presentation/bloc/voice_chat_state.dart`
- **Purpose**: States for `VoiceChatBloc` containing message stream, partial STT text, active AI thinking indicator, and search criteria.

---

## 6. Presentation Layer — Pages & UI Views

### `lib/features/flight_booking/presentation/pages/booking_dialog.dart`
- **Path**: `lib/features/flight_booking/presentation/pages/booking_dialog.dart`
- **Purpose**: Modal form dialog capturing passenger details before booking.

### `lib/features/flight_booking/presentation/pages/ticket_view_page.dart`
- **Path**: `lib/features/flight_booking/presentation/pages/ticket_view_page.dart`
- **Purpose**: Digital flight ticket screen displaying QR code, PNR code, passenger details, seat assignment, and flight breakdown.

### `lib/features/flight_booking/presentation/pages/travel_assistant_page.dart`
- **Path**: `lib/features/flight_booking/presentation/pages/travel_assistant_page.dart`
- **Purpose**: Main application page with voice/chat interface, active filter bar, floating microphone button, and sliding search result sheet.

---

## 7. Presentation Layer — UI Widgets & Components

### `lib/features/flight_booking/presentation/widgets/active_criteria_bar.dart`
- **Path**: `lib/features/flight_booking/presentation/widgets/active_criteria_bar.dart`
- **Purpose**: Horizontal chip bar displaying active search criteria with dismiss buttons.

### `lib/features/flight_booking/presentation/widgets/booking_flow_sheet.dart`
- **Path**: `lib/features/flight_booking/presentation/widgets/booking_flow_sheet.dart`
- **Purpose**: Multi-step bottom sheet for selecting flights and completing booking.

### `lib/features/flight_booking/presentation/widgets/chat_bubble.dart`
- **Path**: `lib/features/flight_booking/presentation/widgets/chat_bubble.dart`
- **Purpose**: Custom styled chat speech bubbles for user messages and assistant responses.

### `lib/features/flight_booking/presentation/widgets/chat_gpt_input_bar.dart`
- **Path**: `lib/features/flight_booking/presentation/widgets/chat_gpt_input_bar.dart`
- **Purpose**: ChatGPT-style text input bar with send and microphone action buttons.

### `lib/features/flight_booking/presentation/widgets/flight_card.dart`
- **Path**: `lib/features/flight_booking/presentation/widgets/flight_card.dart`
- **Purpose**: Flight result card rendering airline logo, timing, layover details, price, and smart badges.

### `lib/features/flight_booking/presentation/widgets/flight_list_sheet.dart`
- **Path**: `lib/features/flight_booking/presentation/widgets/flight_list_sheet.dart`
- **Purpose**: Expandable bottom sheet rendering list of matching flight cards.

### `lib/features/flight_booking/presentation/widgets/flight_results_header.dart`
- **Path**: `lib/features/flight_booking/presentation/widgets/flight_results_header.dart`
- **Purpose**: Header bar displaying match count and current sort mode selector.

### `lib/features/flight_booking/presentation/widgets/gpt_loading_bubble.dart`
- **Path**: `lib/features/flight_booking/presentation/widgets/gpt_loading_bubble.dart`
- **Purpose**: Animated thinking bubble shown while Gemini LLM or Local NLP evaluates prompts.

### `lib/features/flight_booking/presentation/widgets/minimal_mic_button.dart`
- **Path**: `lib/features/flight_booking/presentation/widgets/minimal_mic_button.dart`
- **Purpose**: Animated microphone button toggling audio recording states.

### `lib/features/flight_booking/presentation/widgets/recording_overlay_bar.dart`
- **Path**: `lib/features/flight_booking/presentation/widgets/recording_overlay_bar.dart`
- **Purpose**: Real-time sound wave overlay displayed while voice recording is active.

---

## 8. Documentation & Project Configuration

### `_config.yml`
- **Path**: `_config.yml`
- **Purpose**: GitHub Pages site configuration using `remote_theme: ksauraj/stygian` and `defaults.layout: docs`.

### `pubspec.yaml`
- **Path**: `pubspec.yaml`
- **Purpose**: Package dependencies, Flutter SDK constraints, and asset declarations.
