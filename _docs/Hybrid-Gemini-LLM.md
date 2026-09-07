---
title: Hybrid Gemini LLM Integration
nav_order: 8
---

# 🧠 Hybrid Gemini LLM Integration & Fallback Engine

This document details the online **Google Gemini 1.5 Flash LLM** integration (`HybridAiServiceImpl`), structured JSON schema enforcement, dynamic context payload construction, and deterministic offline fallback.

---

## 🏗️ Architectural Overview

The AI layer follows a **Hybrid Strategy Pattern**:

```mermaid
graph TD
    Client["ParseUserIntentUseCase"] --> Interface["AiService Interface"]
    Interface --> CheckSession{Active Gemini ChatSession?}

    CheckSession -->|Yes (Online API Key Active)| Gemini["HybridAiServiceImpl (Google Gemini 1.5 Flash)"]
    CheckSession -->|No API Key / Network Error / Quota Exhaustion| Local["LocalRuleAiServiceImpl (Zero-Config NLP)"]

    Gemini -->|Returns Raw Structured JSON| ParseJSON["Parse Parameters & Validate Criteria"]
    Local -->|Returns Deterministic Match| Response["Success(AiResult Payload)"]
    ParseJSON --> Response
```

---

## ⚙️ GenerativeModel Setup & JSON Schema Enforcement (`ai_service.dart`)

When a valid key (`AIzaSy...` or `AQ...`) is registered via `setApiKey(key)`, `HybridAiServiceImpl` initializes `GenerativeModel`:

```dart
_model = GenerativeModel(
  model: 'gemini-1.5-flash',
  apiKey: key.trim(),
  systemInstruction: Content.system(kSystemPrompt),
  generationConfig: GenerationConfig(
    responseMimeType: 'application/json',
    temperature: 0.2, // Low temperature ensures consistent deterministic JSON output
  ),
);
_chatSession = _model!.startChat();
```

---

## 📄 Enforced System Prompt (`api_constants.dart`)

```json
{
  "action": "GREETING | ASK_CLARIFICATION | SEARCH_FLIGHTS | CONFIRM_BOOKING | CANCEL_BOOKING",
  "spoken_response": "1-2 natural sentences summarizing matches or asking missing fields",
  "parameters": {
    "origin": "Mumbai",
    "destination": "Dubai",
    "departure_date": "2026-10-07",
    "max_price": 25000,
    "max_duration": 360,
    "direct_only": true,
    "sort_preference": "FASTEST",
    "selected_flight_index": null
  },
  "missing_parameters": ["departure_date"],
  "expected_parameter": "departure_date"
}
```

---

## 💬 Dynamic Context Payload Construction

When sending prompts to Gemini, the service injects current search criteria context so that incremental prompts (*"make it cheaper"*, *"change date to 7"*) retain existing parameters:

```dart
final userMessage = """
User Input: "$userPrompt"
Current Context Parameters: ${jsonEncode({
  'origin': currentCriteria.origin,
  'destination': currentCriteria.destination,
  'departure_date': currentCriteria.dateText,
  'max_price': currentCriteria.maxPrice,
  'direct_only': currentCriteria.directOnly,
  'last_expected_parameter': lastExpectedParameter,
})}
""";
```

---

## 🛡️ Fallback Matrix & Resiliency

`HybridAiServiceImpl` automatically catches exceptions and delegates execution to `LocalRuleAiServiceImpl` under the following conditions:

| Exception Trigger | Root Cause | Fallback Behavior |
|:---|:---|:---|
| **`apiKey == null`** | Uninitialized key state | Instantly invokes `LocalRuleAiServiceImpl.parseUserPrompt()`. No network call initiated. |
| **HTTP 401 / 403** | Invalid API key | Caught silently in `try/catch`; delegates prompt to local NLP. |
| **HTTP 429 Quota Exhaustion** | Gemini API rate limit exceeded | Caught silently; falls back to local NLP engine without throwing errors. |
| **SocketException / Offline** | Device disconnected from internet | Caught silently; processes query using offline rule engine. |
