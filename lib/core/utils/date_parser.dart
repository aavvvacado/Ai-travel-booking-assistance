import 'package:intl/intl.dart';

class DateParser {
  DateParser._();

  /// Parse conversational dates like "next weekend", "tomorrow", "next Saturday", "nex week" into a normalized DateTime
  static DateTime? parseConversationalDate(String text) {
    final lower = text.toLowerCase().trim();
    final now = DateTime.now();

    if (lower.contains('today')) {
      return now;
    } else if (lower.contains('tomorrow') || lower.contains('tomorow') || lower.contains('tomm') || lower.contains('tmw')) {
      return now.add(const Duration(days: 1));
    } else if (lower.contains('day after tomorrow')) {
      return now.add(const Duration(days: 2));
    } else if (lower.contains('next weekend') || lower.contains('nxt weekend') || lower.contains('nex weekend')) {
      int daysUntilSaturday = (DateTime.saturday - now.weekday + 7) % 7;
      if (daysUntilSaturday == 0) daysUntilSaturday = 7;
      return now.add(Duration(days: daysUntilSaturday));
    } else if (lower.contains('this weekend')) {
      int daysUntilSaturday = (DateTime.saturday - now.weekday + 7) % 7;
      return now.add(Duration(days: daysUntilSaturday == 0 ? 0 : daysUntilSaturday));
    } else if (lower.contains('next week') || lower.contains('nex week') || lower.contains('nxt week') || lower.contains('coming week')) {
      return now.add(const Duration(days: 7));
    } else if (lower.contains('flexible') || lower.contains('anytime') || lower.contains('any day') || lower.contains('any date') || lower.contains('soon')) {
      return now.add(const Duration(days: 7));
    }

    // Days of week check: "next monday", "this friday", "saturday", "nex saturday"
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
      if (lower.contains(entry.key)) {
        int targetDay = entry.value;
        int diff = (targetDay - now.weekday + 7) % 7;
        if (diff == 0 || lower.contains('next') || lower.contains('nex') || lower.contains('nxt')) {
          diff += 7;
        }
        return now.add(Duration(days: diff));
      }
    }

    // Try standard formats e.g. "2026-09-12" or "12 Sep"
    try {
      if (RegExp(r'\d{4}-\d{2}-\d{2}').hasMatch(text)) {
        return DateTime.parse(text);
      }
    } catch (_) {}

    return null;
  }

  static String formatDate(DateTime date) {
    return DateFormat('EEE, d MMM yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  static String formatTime(String time24) {
    try {
      final parts = time24.split(':');
      final time = DateTime(2026, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat('h:mm a').format(time);
    } catch (_) {
      return time24;
    }
  }
}
