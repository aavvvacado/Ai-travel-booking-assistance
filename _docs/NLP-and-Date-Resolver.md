---
title: NLP & Date Resolver
nav_order: 4
---

# NLP & Date Resolver Engine

Natural language travel queries contain complex relative expressions, date offsets, or composite constraints. The `DateResolver` and `LocalRuleAiServiceImpl` provide deterministic intent parsing and date calculation.

---

## 📅 Date Expression Parsing

The `DateResolver` uses the application reference date (**Sep 7, 2026**) as an anchor to compute exact `DateTime` preferences:

| User Prompt | Resolved Date Type | Output Date(s) |
|:---|:---|:---|
| `"tomorrow"` | Exact Date | Sep 8, 2026 |
| `"next weekend"` | Date Range | Sep 12, 2026 – Sep 13, 2026 |
| `"next week"` | Date Range | Sep 14, 2026 – Sep 20, 2026 |
| `"next month 7"` / `"7th of next month"` | Exact Date | Oct 7, 2026 |
| `"next weekend after the 12th"` | Date Range Offset | Sep 19, 2026 – Sep 20, 2026 |
| `"flexible"` / `"anytime"` | Flexible Date | Any date range |

---

## 🔄 Bidirectional Layover, Duration & Price Preferences

The NLP engine matches phrases in both directions (lesser vs. higher / cheap vs. expensive) and updates `SearchCriteria`:

| Matched Phrases | Applied SortPreference | Applied Constraint |
|:---|:---|:---|
| `"lesser layover"`, `"shorter duration"`, `"min layover"` | `SortPreference.fastest` | Ranks shortest total duration first |
| `"higher layover"`, `"more duration"`, `"longer layover"` | `SortPreference.longest` | Ranks longer total journeys first |
| `"cheapest"`, `"lowest fare"`, `"under 20k"` | `SortPreference.cheapest` | Caps max price at parsed value |
| `"expensive"`, `"premium"`, `"costliest"` | `SortPreference.expensive` | Ranks premium business fares first |
| `"direct"`, `"non-stop"`, `"no layover"` | Unchanged | `directOnly = true` |
