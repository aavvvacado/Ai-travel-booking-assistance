import '../../features/flight_booking/domain/entities/travel_date_preference.dart';

class DateResolver {
  const DateResolver();

  /// Reference application date (e.g. 2026-09-07)
  static DateTime get defaultNow => DateTime(2026, 9, 7);

  /// Main method to resolve natural language expressions into TravelDatePreference
  TravelDatePreference resolve(
    String input, {
    DateTime? referenceDate,
    DateTime? anchorDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    var cleanInput = input.trim().toLowerCase();

    // Remove negated phrases to avoid parsing them (e.g., "not 6 september", "not tomorrow")
    final notPattern = RegExp(r'\bnot\s+([a-z0-9\s]+)', caseSensitive: false);
    cleanInput = cleanInput.replaceAll(notPattern, '');

    // 1. Check flexible/anytime
    if (cleanInput.contains('flexible') ||
        cleanInput.contains('anytime') ||
        cleanInput.contains('any day') ||
        cleanInput.contains('any date') ||
        cleanInput.contains('dont care about date')) {
      return TravelDatePreference.flexible(originalExpression: input);
    }

    // 2. Check explicitly stated date range offset e.g., "weekend after the 12th" or "after 12 sep" or "after 12th"
    DateTime? explicitAnchor = anchorDate;
    final afterDayMatch = RegExp(r'(?:after|past|following)\s+(?:the\s+)?(\d{1,2})(?:st|nd|rd|th)?(?: \w+)?', caseSensitive: false).firstMatch(cleanInput);
    if (afterDayMatch != null) {
      final dayNum = int.tryParse(afterDayMatch.group(1)!);
      if (dayNum != null) {
        explicitAnchor = DateTime(now.year, now.month, dayNum);
      }
    }

    // 3. "Weekend after next" / "weekend after 12th" / "next weekend after 12th"
    if (cleanInput.contains('weekend after') ||
        cleanInput.contains('weekend after next') ||
        (cleanInput.contains('weekend') && explicitAnchor != null)) {
      final baseDate = explicitAnchor ?? _getNextSaturday(now);
      final sat = _getNextSaturday(baseDate.add(const Duration(days: 1)));
      final sun = sat.add(const Duration(days: 1));
      return TravelDatePreference.range(
        sat,
        sun,
        originalExpression: input,
      );
    }

    // 4. "Next weekend" / "coming weekend" / "this weekend"
    if (cleanInput.contains('next weekend') ||
        cleanInput.contains('nxt weekend') ||
        cleanInput.contains('coming weekend')) {
      // Find upcoming Saturday
      final sat = _getNextSaturday(now);
      final sun = sat.add(const Duration(days: 1));
      return TravelDatePreference.range(
        sat,
        sun,
        originalExpression: input,
      );
    }

    // 4.5. "Next week" / "this week" / "next month"
    if (cleanInput.contains('next week') || cleanInput.contains('nxt week')) {
      int daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
      if (daysUntilMonday == 0) daysUntilMonday = 7;
      final nextMon = now.add(Duration(days: daysUntilMonday));
      final nextSun = nextMon.add(const Duration(days: 6));
      return TravelDatePreference.range(
        nextMon,
        nextSun,
        originalExpression: input,
      );
    }

    if (cleanInput.contains('this week')) {
      final thisMon = now.subtract(Duration(days: now.weekday - 1));
      final thisSun = thisMon.add(const Duration(days: 6));
      return TravelDatePreference.range(
        thisMon,
        thisSun,
        originalExpression: input,
      );
    }

    // Next month with explicit day number e.g. "next month 7", "7th of next month", "next month on 7th"
    final nextMonthDayMatch = RegExp(
      r'(?:next|nxt|following)\s+month\s+(?:on\s+)?(?:the\s+)?(?:date\s+)?(\d{1,2})(?:st|nd|rd|th)?|(\d{1,2})(?:st|nd|rd|th)?\s+(?:of\s+)?(?:next|nxt|following)\s+month',
      caseSensitive: false,
    ).firstMatch(cleanInput);

    if (nextMonthDayMatch != null) {
      final dayStr = nextMonthDayMatch.group(1) ?? nextMonthDayMatch.group(2);
      if (dayStr != null) {
        final dayNum = int.tryParse(dayStr);
        if (dayNum != null && dayNum >= 1 && dayNum <= 31) {
          final targetMonth = now.month + 1;
          final targetYear = targetMonth > 12 ? now.year + 1 : now.year;
          final normMonth = targetMonth > 12 ? 1 : targetMonth;
          return TravelDatePreference.exact(
            DateTime(targetYear, normMonth, dayNum),
            originalExpression: input,
          );
        }
      }
    }

    // Explicit day change phrases like "date to 7", "change date to 7", "date 7", "on 7th"
    final dayNumMatch = RegExp(
      r'\b(?:date\s+(?:to\s+)?|on\s+(?:the\s+)?|change\s+date\s+to\s+)(\d{1,2})(?:st|nd|rd|th)?\b',
      caseSensitive: false,
    ).firstMatch(cleanInput);

    if (dayNumMatch != null) {
      final dayNum = int.tryParse(dayNumMatch.group(1)!);
      if (dayNum != null && dayNum >= 1 && dayNum <= 31) {
        int month = now.month;
        int year = now.year;
        if (dayNum < now.day) {
          month += 1;
          if (month > 12) {
            month = 1;
            year += 1;
          }
        }
        return TravelDatePreference.exact(
          DateTime(year, month, dayNum),
          originalExpression: input,
        );
      }
    }

    if (cleanInput.contains('next month')) {
      final nextMonthStart = DateTime(now.year, now.month + 1, 1);
      final nextMonthEnd = DateTime(now.year, now.month + 2, 0);
      return TravelDatePreference.range(
        nextMonthStart,
        nextMonthEnd,
        originalExpression: input,
      );
    }

    if (cleanInput.contains('this weekend')) {
      int daysUntilSat = (DateTime.saturday - now.weekday + 7) % 7;
      final sat = now.add(Duration(days: daysUntilSat));
      final sun = sat.add(const Duration(days: 1));
      return TravelDatePreference.range(
        sat,
        sun,
        originalExpression: input,
      );
    }

    // 5. "Today", "Tomorrow", "Day after tomorrow"
    if (cleanInput.contains('today')) {
      return TravelDatePreference.exact(now, originalExpression: input);
    }

    if (cleanInput.contains('day after tomorrow')) {
      return TravelDatePreference.exact(now.add(const Duration(days: 2)), originalExpression: input);
    }

    if (cleanInput.contains('tomorrow') || cleanInput.contains('tomorow') || cleanInput.contains('tmw')) {
      return TravelDatePreference.exact(now.add(const Duration(days: 1)), originalExpression: input);
    }

    // 6. Days of Week: "next monday", "this saturday", "saturday", "sunday"
    final daysOfWeek = {
      'monday': DateTime.monday,
      'mon': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'tue': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'wed': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'thu': DateTime.thursday,
      'friday': DateTime.friday,
      'fri': DateTime.friday,
      'saturday': DateTime.saturday,
      'sat': DateTime.saturday,
      'sunday': DateTime.sunday,
      'sun': DateTime.sunday,
    };

    for (final entry in daysOfWeek.entries) {
      if (RegExp('\\b${entry.key}\\b', caseSensitive: false).hasMatch(cleanInput)) {
        final targetWeekday = entry.value;
        int diff = (targetWeekday - now.weekday + 7) % 7;

        if (cleanInput.contains('next') || cleanInput.contains('nxt')) {
          if (diff == 0) diff += 7;
        }

        final targetDate = now.add(Duration(days: diff));
        return TravelDatePreference.exact(targetDate, originalExpression: input);
      }
    }

    // 7. Explicit date parsing: e.g. "12 Sep", "12th September", "September 12", "2026-09-12"
    final explicitDate = _parseExplicitDate(input, referenceDate: now);
    if (explicitDate != null) {
      return TravelDatePreference.exact(explicitDate, originalExpression: input);
    }

    // 8. Fallback: if nothing recognized, return relative exact date to today
    return TravelDatePreference.exact(now, originalExpression: input);
  }

  static DateTime _getNextSaturday(DateTime from) {
    int daysUntilSaturday = (DateTime.saturday - from.weekday + 7) % 7;
    if (daysUntilSaturday == 0) daysUntilSaturday = 7;
    return from.add(Duration(days: daysUntilSaturday));
  }

  static DateTime? _parseExplicitDate(String text, {required DateTime referenceDate}) {
    try {
      // YYYY-MM-DD
      final isoMatch = RegExp(r'\b(\d{4})-(\d{2})-(\d{2})\b').firstMatch(text);
      if (isoMatch != null) {
        return DateTime.parse(isoMatch.group(0)!);
      }

      // 12 Sep / 12th September / 12 September
      final dayMonthMatch = RegExp(
        r'\b(\d{1,2})(?:st|nd|rd|th)?\s+(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\b',
        caseSensitive: false,
      ).firstMatch(text);

      if (dayMonthMatch != null) {
        final day = int.parse(dayMonthMatch.group(1)!);
        final monthStr = dayMonthMatch.group(2)!;
        final month = _monthToNum(monthStr);
        return DateTime(referenceDate.year, month, day);
      }

      // September 12 / Sep 12th
      final monthDayMatch = RegExp(
        r'\b(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\s+(\d{1,2})(?:st|nd|rd|th)?\b',
        caseSensitive: false,
      ).firstMatch(text);

      if (monthDayMatch != null) {
        final monthStr = monthDayMatch.group(1)!;
        final day = int.parse(monthDayMatch.group(2)!);
        final month = _monthToNum(monthStr);
        return DateTime(referenceDate.year, month, day);
      }
    } catch (_) {}

    return null;
  }

  static int _monthToNum(String monthStr) {
    final m = monthStr.toLowerCase();
    if (m.startsWith('jan')) return 1;
    if (m.startsWith('feb')) return 2;
    if (m.startsWith('mar')) return 3;
    if (m.startsWith('apr')) return 4;
    if (m.startsWith('may')) return 5;
    if (m.startsWith('jun')) return 6;
    if (m.startsWith('jul')) return 7;
    if (m.startsWith('aug')) return 8;
    if (m.startsWith('sep')) return 9;
    if (m.startsWith('oct')) return 10;
    if (m.startsWith('nov')) return 11;
    if (m.startsWith('dec')) return 12;
    return 9;
  }
}
