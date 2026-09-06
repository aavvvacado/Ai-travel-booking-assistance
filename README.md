# AI Travel Booking Assistant

A voice-based AI travel booking assistant built with Flutter. This application allows users to have natural, conversational interactions to search for flights, refine their requirements, and complete a mock booking using a local travel dataset.

## 🚀 Features

- **Conversational Voice Interface**: Speak naturally to the assistant to search for flights. Supports Speech-to-Text (STT) and Text-to-Speech (TTS).
- **Smart AI Understanding**: Understands complex queries like *"I want to fly from Mumbai to Dubai next weekend. I want the cheapest option, but I don't want a long layover."*
- **Dynamic Context Management**: Change requirements mid-conversation (e.g., *"Actually, make it next Saturday"* or *"I want the most expensive flight"*), and the AI will contextually update the search.
- **Hybrid AI Architecture**: Powered primarily by **Google Gemini 1.5 Flash** for deep natural language understanding, with a robust **Local Rule-Based NLP Fallback** to handle API limits or network failures gracefully.
- **Smart Filtering & Badging**: Automatically sorts and badges flights based on explicit conversational constraints (cheapest, fastest, premium, longest).
- **Mock Booking Flow**: Select a flight from the generated mock dataset and seamlessly complete a booking to receive a generated PNR and digital ticket.

---

## 🛠 Setup Instructions

1. **Prerequisites**:
   - Flutter SDK (stable channel)
   - Android Studio / Xcode for emulators
   - A valid Google Gemini API Key

2. **Installation**:
   ```bash
   git clone <repository_url>
   cd aitravelbookingassistance
   flutter pub get
   ```

3. **API Key Setup**:
   The app uses Gemini 1.5 Flash. You can provide the API key directly in the UI when the app launches (via the settings/API key dialog), or inject it during runtime. 
   *(Note: If no API key is provided, the app will seamlessly degrade to its Local Rule-Based NLP engine).*

4. **Run the App**:
   ```bash
   flutter run
   ```

---

## 🏗 Architecture & Application Layers

The application is structured using **Feature-Driven Clean Architecture**. This ensures that the UI is decoupled from the business logic, and the business logic is decoupled from external services (like the AI API or the local dataset). 

```mermaid
graph TD
    %% UI Layer
    subgraph Presentation Layer [Presentation Layer (UI & BLoC)]
        UI[Flutter UI Widgets]
        VCB[VoiceChatBloc]
        BB[BookingBloc]
    end

    %% Domain Layer
    subgraph Domain Layer [Domain Layer (Business Logic)]
        SC[SearchCriteria Entity]
        FSS[FlightSearchService]
        DR[DateResolver]
    end

    %% Data Layer
    subgraph Data / Core Layer [Data & Core Services]
        FDS[FlightLocalDataSource]
        AI[AiService Interface]
        Speech[SpeechService]
        Gemini[HybridAiServiceImpl]
        Local[LocalRuleAiServiceImpl]
    end

    %% Connections
    UI -->|Triggers Speech| Speech
    Speech -->|Yields Text| VCB
    VCB -->|Sends Text & Context| AI
    AI -->|Returns JSON Intent| VCB
    VCB -->|Yields Intent| BB
    BB -->|Updates Criteria| SC
    BB -->|Requests Search| FSS
    FSS -->|Fetches Mock Data| FDS
    FSS -->|Sorts & Filters| FSS
    BB -->|Yields Results| UI
    
    AI <|-- Gemini
    AI <|-- Local
```

### 1. Core Layer (`lib/core/`)
This layer contains globally accessible utilities, dependency injection setup (`ServiceLocator`), and abstracted service interfaces. By abstracting the `AiService` behind an interface, the app can easily switch between different AI providers without changing a single line of UI code.

### 2. Data Layer (`lib/features/flight_booking/data/`)
Responsible for data retrieval. 
- **`FlightLocalDataSource`**: Acts as our mock database. It generates and stores over 200 realistic flight mockups using deterministic rules. If this were a real application, this layer would be swapped out for a network repository calling an Amadeus or Skyscanner API, while the rest of the app would remain entirely unchanged.

### 3. Domain Layer (`lib/features/flight_booking/domain/`)
The absolute core of the application where business rules live.
- **Entities**: Pure data models like `Flight`, `SearchCriteria`, and `BookingConfirmation`.
- **`FlightSearchService`**: The engine that filters and sorts the mock data based on the dynamic constraints requested by the user (price limits, duration, direct-only, sorting preference).
- **`DateResolver`**: A specialized business logic unit that converts relative conversational dates ("next weekend", "tomorrow") into concrete `DateTime` objects.

### 4. Presentation Layer (`lib/features/flight_booking/presentation/`)
The reactive UI layer. It only knows how to display states and emit events.
- Contains the BLoCs (State Management) and all the visual Flutter components (`FlightCard`, `ChatGptInputBar`).

---

## ⚙️ State-Management Approach

The application uses **Flutter BLoC (`flutter_bloc`)** for state management, enforcing a strict unidirectional data flow. The state is divided into two distinct BLoCs to prevent monolithic state classes and clearly separate concerns:

### 1. `VoiceChatBloc` (Conversational State)
- **Responsibility**: Manages everything related to the voice interface and AI communication.
- **Flow**:
  1. User presses the mic button (emits `StartListening` event).
  2. The bloc interfaces with `SpeechService` to get a transcript.
  3. The transcript is sent to the `AiService` alongside the user's current context (to allow for follow-up questions).
  4. The AI returns a structured JSON intent. The bloc emits a state containing the AI's spoken response (triggering Text-To-Speech) and the parsed `intent`.

### 2. `BookingBloc` (Domain/Data State)
- **Responsibility**: Manages the actual travel data, flight results, and booking flows.
- **Flow**:
  1. A `BlocListener` in the UI listens for `intent` payloads emitted by the `VoiceChatBloc`.
  2. When an intent arrives, it dispatches an event to the `BookingBloc` (e.g., `ProcessAiIntent`).
  3. The `BookingBloc` determines the action (`SEARCH_FLIGHTS`, `CONFIRM_BOOKING`, `CANCEL_BOOKING`).
  4. If searching, it calls `FlightSearchService`, applies the AI-determined filters (price, duration, etc.), and emits a `BookingSearchSuccess` state containing the sorted flights.
  5. The UI reacts to this state by rendering the list of `FlightCard` widgets.

This multi-bloc architecture ensures that the UI is extremely snappy—the voice recognition UI updates instantly via `VoiceChatBloc`, while the heavy data filtering happens asynchronously in the `BookingBloc`.

---

## 🧠 AI Integration

The intelligence layer is abstracted behind an `AiService` interface, implemented as a **Hybrid System**:

1. **Gemini 1.5 Flash (`HybridAiServiceImpl`)**:
   - A highly detailed System Prompt instructs the LLM to act as a travel advisor.
   - The LLM receives the user's transcript and the *current conversation context* (origin, dates, budgets).
   - It outputs strict JSON containing an `action` (Greeting, Search, Confirm, Cancel), updated search parameters, and a natural language response.
2. **Local Rule-Based Fallback (`LocalRuleAiServiceImpl`)**:
   - If the API fails, times out, or the user hasn't provided a key, this local engine takes over.
   - Uses Regex, string matching, and a custom `DateResolver` to extract cities, dates (e.g., "next weekend"), budgets, and sorting preferences natively.
   
This hybrid approach completely fulfills the **Edge Case requirement** of handling AI/API failures.

---

## 🎯 Key Technical Decisions

1. **Structured JSON Enforcement**: Instead of parsing raw text from the AI, the system prompt forces the LLM to return structured JSON. This guarantees deterministic behavior in the UI while keeping the conversational aspect fluid.
2. **Custom Date Resolver**: "Next weekend" or "Tomorrow" means nothing to a database. I built a `DateResolver` that translates relative natural language into concrete `DateTime` ranges using the device's current date as an anchor.
3. **Smart Badging over "Over-Smart" AI**: The AI only highlights options (e.g., "✓ Cheapest", "✓ Premium option") if the user explicitly asks for those constraints. If the user just wants a simple search, it returns raw, unbiased data to prevent frustrating UX.
4. **Resilient Keyboard/Voice UI**: The input bar dynamically expands and handles transcription in real-time, preventing keyboard overlaps (`resizeToAvoidBottomInset` tuning).

---

## ⚠️ Known Limitations

1. **Voice Recognition Accuracy**: The app relies on the native OS speech recognition (`speech_to_text`). Accuracy in noisy environments depends on the device's built-in microphone and OS-level models.
2. **Mock Dataset Scope**: The local dataset contains roughly 200 generated flights focusing on major hubs (BOM, DEL, DXB, LHR, JFK, SIN). Searching for unsupported obscure cities will correctly trigger the "No matching flights" edge-case handler.
3. **LLM Hallucinations**: While strictly prompted to output JSON, generative models can occasionally hallucinate formatting. The app uses `try-catch` blocks in the JSON decoding phase to instantly failover to the local rule-based AI if a formatting error occurs.

---

## 🎥 Demo / Walkthrough
https://drive.google.com/file/d/1H8YT0mk2NEPlIFceYu4uOMC6S6A47m4-/view?usp=sharing
*(Please refer to the attached video file submitted alongside this repository for a complete walkthrough of the voice interactions, edge cases, and mock booking flow.)*
