---
title: Troubleshooting
nav_order: 7
---

# Troubleshooting & Frequently Asked Questions

Diagnostic solutions for common issues, edge cases, and API key setup questions.

---

## ❓ Frequently Asked Questions

### 1. Why does the app answer instantly without showing network delay?
If no valid Google Gemini API key is provided or if network connectivity is disabled, the app uses its zero-config `LocalRuleAiServiceImpl`. To test online Gemini reasoning, click the key icon (🔑) in the top bar and enter your key.

### 2. How does "next month 7" get resolved?
The `DateResolver` evaluates the application reference date (**Sep 7, 2026**) and matches composite expressions like `"next month 7"` or `"7th of next month"` to return an exact date of **October 7th, 2026**.

### 3. What happens if I ask for "lesser layover or duration"?
The NLP engine detects layover/duration preferences and updates `SearchCriteria.sortPreference` to `SortPreference.fastest`, sorting flights with shortest total travel time and direct/minimum layover options at the top.

---

## ⚠️ Edge Cases & Troubleshooting

> **Microphone Permission Denied**: If speech input does not register, ensure microphone permissions are granted in device settings:
> - **Android**: Settings → Apps → AI Travel Assistant → Permissions → Microphone → Allow.
> - **iOS**: Settings → AI Travel Assistant → Microphone → Enable.

> **API Key Format**: API keys starting with `AQ...` or standard `AIzaSy...` keys are supported. If Gemini API throws HTTP 400 or quota errors, the app seamlessly falls back to local NLP rules without crashing.
