import 'package:equatable/equatable.dart';
import 'travel_date_preference.dart';

enum SortPreference { cheapest, expensive, fastest, longest, earliest, latest, none }

class SearchCriteria extends Equatable {
  final String? origin;
  final String? originCode;
  final String? destination;
  final String? destinationCode;
  final TravelDatePreference? datePreference;
  final String? originalDateExpression;
  final double? maxPrice;
  final int? maxDuration; // in minutes
  final bool? directOnly;
  final int? maxStops;
  final int passengerCount;
  final String cabinClass;
  final SortPreference sortPreference;
  final String? preferredAirline;

  const SearchCriteria({
    this.origin,
    this.originCode,
    this.destination,
    this.destinationCode,
    this.datePreference,
    this.originalDateExpression,
    this.maxPrice,
    this.maxDuration,
    this.directOnly,
    this.maxStops,
    this.passengerCount = 1,
    this.cabinClass = 'Economy',
    this.sortPreference = SortPreference.none,
    this.preferredAirline,
  });

  /// Helper getter for legacy/display single DateTime if exact
  DateTime? get date => datePreference?.startDate;

  /// Helper getter for legacy date text display
  String? get dateText => datePreference?.formatSummary() ?? originalDateExpression;

  bool get isComplete =>
      origin != null &&
      origin!.trim().isNotEmpty &&
      destination != null &&
      destination!.trim().isNotEmpty &&
      datePreference != null;

  List<String> get missingFields {
    final list = <String>[];
    if (origin == null || origin!.trim().isEmpty) list.add('origin city');
    if (destination == null || destination!.trim().isEmpty) list.add('destination city');
    if (datePreference == null) list.add('departure date');
    return list;
  }

  SearchCriteria copyWith({
    String? origin,
    String? originCode,
    String? destination,
    String? destinationCode,
    TravelDatePreference? datePreference,
    String? originalDateExpression,
    double? maxPrice,
    int? maxDuration,
    bool? directOnly,
    int? maxStops,
    int? passengerCount,
    String? cabinClass,
    SortPreference? sortPreference,
    String? preferredAirline,
  }) {
    return SearchCriteria(
      origin: origin ?? this.origin,
      originCode: originCode ?? this.originCode,
      destination: destination ?? this.destination,
      destinationCode: destinationCode ?? this.destinationCode,
      datePreference: datePreference ?? this.datePreference,
      originalDateExpression: originalDateExpression ?? this.originalDateExpression,
      maxPrice: maxPrice ?? this.maxPrice,
      maxDuration: maxDuration ?? this.maxDuration,
      directOnly: directOnly ?? this.directOnly,
      maxStops: maxStops ?? this.maxStops,
      passengerCount: passengerCount ?? this.passengerCount,
      cabinClass: cabinClass ?? this.cabinClass,
      sortPreference: sortPreference ?? this.sortPreference,
      preferredAirline: preferredAirline ?? this.preferredAirline,
    );
  }

  @override
  List<Object?> get props => [
        origin,
        originCode,
        destination,
        destinationCode,
        datePreference,
        originalDateExpression,
        maxPrice,
        maxDuration,
        directOnly,
        maxStops,
        passengerCount,
        cabinClass,
        sortPreference,
        preferredAirline,
      ];
}
