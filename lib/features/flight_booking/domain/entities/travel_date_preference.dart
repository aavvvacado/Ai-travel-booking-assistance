import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

enum DatePreferenceType {
  exactDate,
  dateRange,
  relativeDate,
  flexible,
}

class TravelDatePreference extends Equatable {
  final DatePreferenceType type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? originalExpression;

  const TravelDatePreference({
    required this.type,
    this.startDate,
    this.endDate,
    this.originalExpression,
  });

  factory TravelDatePreference.exact(DateTime date, {String? originalExpression}) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    return TravelDatePreference(
      type: DatePreferenceType.exactDate,
      startDate: cleanDate,
      endDate: cleanDate,
      originalExpression: originalExpression,
    );
  }

  factory TravelDatePreference.range(
    DateTime start,
    DateTime end, {
    String? originalExpression,
  }) {
    final cleanStart = DateTime(start.year, start.month, start.day);
    final cleanEnd = DateTime(end.year, end.month, end.day);
    return TravelDatePreference(
      type: DatePreferenceType.dateRange,
      startDate: cleanStart,
      endDate: cleanEnd,
      originalExpression: originalExpression,
    );
  }

  factory TravelDatePreference.flexible({String? originalExpression}) {
    return TravelDatePreference(
      type: DatePreferenceType.flexible,
      originalExpression: originalExpression ?? 'Flexible',
    );
  }

  bool get isRange =>
      type == DatePreferenceType.dateRange &&
      startDate != null &&
      endDate != null &&
      startDate != endDate;

  bool matchesDate(DateTime date) {
    if (type == DatePreferenceType.flexible || startDate == null) return true;

    final target = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate!.year, startDate!.month, startDate!.day);

    if (endDate == null || endDate == startDate) {
      return target.year == start.year && target.month == start.month && target.day == start.day;
    }

    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
    return (target.isAfter(start) || target.isAtSameMomentAs(start)) &&
        (target.isBefore(end) || target.isAtSameMomentAs(end));
  }

  String formatSummary() {
    if (type == DatePreferenceType.flexible) {
      return 'Flexible dates';
    }

    if (startDate == null) return originalExpression ?? 'Dates pending';

    final startStr = DateFormat('d MMM yyyy').format(startDate!);

    if (endDate == null || endDate == startDate) {
      return startStr;
    }

    final endStr = DateFormat('d MMM yyyy').format(endDate!);
    if (startDate!.month == endDate!.month) {
      return '${DateFormat('d').format(startDate!)}–${DateFormat('d MMM yyyy').format(endDate!)}';
    }

    return '$startStr–$endStr';
  }

  @override
  List<Object?> get props => [type, startDate, endDate, originalExpression];
}
