---
title: Hybrid Gemini LLM
nav_order: 5
---

# Hybrid Gemini LLM Integration

The intelligence layer is abstracted behind an `AiService` interface, implementing a hybrid design pattern that balances cloud LLM reasoning with instant offline fallback.

---

## 🧠 System Prompt & Structured JSON Enforcement

When online reasoning is active, `HybridAiServiceImpl` initializes Google Gemini 1.5 Flash using `GenerativeModel` with `responseMimeType: 'application/json'`.

```json
{
  "action": "GREETING | ASK_CLARIFICATION | SEARCH_FLIGHTS | CONFIRM_BOOKING | CANCEL_BOOKING",
  "spoken_response": "Short natural response explaining the matches (1-2 sentences)",
  "parameters": {
    "origin": "Mumbai",
    "destination": "Dubai",
    "departure_date": "2026-10-07",
    "max_price": 25000,
    "max_duration": 400,
    "direct_only": true,
    "sort_preference": "FASTEST",
    "selected_flight_index": null
  },
  "missing_parameters": [],
  "expected_parameter": null
}
```

---

## 🛡️ Seamless Fallback Architecture

If any of the following occur:
- No API key configured (or uninitialized session)
- Network request timeout or offline state
- Google API quota limit or 429 error

The application instantly catches the exception and delegates prompt parsing to `LocalRuleAiServiceImpl` without throwing errors to the user.
