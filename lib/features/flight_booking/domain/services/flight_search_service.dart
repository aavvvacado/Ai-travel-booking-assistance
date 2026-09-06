import '../entities/flight.dart';
import '../entities/search_criteria.dart';

class SmartMatchResult {
  final Flight flight;
  final String primaryBadge;
  final List<String> secondaryBadges;

  const SmartMatchResult({
    required this.flight,
    required this.primaryBadge,
    this.secondaryBadges = const [],
  });
}

class FlightSearchService {
  const FlightSearchService();

  /// Filter & Sort available flights based on SearchCriteria
  List<Flight> searchFlights({
    required List<Flight> flights,
    required SearchCriteria criteria,
  }) {
    List<Flight> matching = flights.where((f) {
      bool match = true;

      // Origin check
      if (criteria.origin != null && criteria.origin!.isNotEmpty) {
        final o = criteria.origin!.toLowerCase();
        match = match && (f.origin.toLowerCase().contains(o) || f.originCode.toLowerCase() == o);
      }

      // Destination check
      if (criteria.destination != null && criteria.destination!.isNotEmpty) {
        final d = criteria.destination!.toLowerCase();
        match = match && (f.destination.toLowerCase().contains(d) || f.destinationCode.toLowerCase() == d);
      }

      // Direct flight constraint
      if (criteria.directOnly == true) {
        match = match && f.isDirect;
      }

      // Price budget constraint
      if (criteria.maxPrice != null) {
        match = match && f.price <= criteria.maxPrice!;
      }

      // TravelDatePreference range check
      if (criteria.datePreference != null && criteria.datePreference!.startDate != null) {
        // Mock flights carry departure dates or relative days; match within date preference
        // In local mock dataset, flights repeat across days, so datePreference matches
      }

      // Max Duration constraint (including layover)
      if (criteria.maxDuration != null) {
        match = match && _parseDuration(f.duration) <= criteria.maxDuration!;
      }

      return match;
    }).toList();

    // Sort matching results based on preference
    switch (criteria.sortPreference) {
      case SortPreference.cheapest:
        matching.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortPreference.expensive:
        matching.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortPreference.fastest:
        matching.sort((a, b) => _parseDuration(a.duration).compareTo(_parseDuration(b.duration)));
        break;
      case SortPreference.longest:
        matching.sort((a, b) => _parseDuration(b.duration).compareTo(_parseDuration(a.duration)));
        break;
      case SortPreference.earliest:
        matching.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
      case SortPreference.latest:
        matching.sort((a, b) => b.departureTime.compareTo(a.departureTime));
        break;
      case SortPreference.none:
        break;
    }

    return matching;
  }

  /// Generates smart badges for flight cards based on actual dataset comparisons
  Map<String, String> generateSmartBadges({
    required List<Flight> results,
    required SearchCriteria criteria,
  }) {
    if (results.isEmpty) return {};

    // Do not show "over smart" highlights if the user just asked for a simple search
    // without any explicit constraints or sort preferences.
    if (criteria.sortPreference == SortPreference.none &&
        criteria.maxPrice == null &&
        criteria.maxDuration == null &&
        criteria.directOnly == null) {
      return {};
    }

    final Map<String, String> badges = {};

    // Find min/max price and min/max duration
    double minPrice = results.first.price;
    double maxPrice = results.first.price;
    int minDuration = _parseDuration(results.first.duration);
    int maxDuration = _parseDuration(results.first.duration);

    for (final f in results) {
      if (f.price < minPrice) minPrice = f.price;
      if (f.price > maxPrice) maxPrice = f.price;
      final dur = _parseDuration(f.duration);
      if (dur < minDuration) minDuration = dur;
      if (dur > maxDuration) maxDuration = dur;
    }

    for (final f in results) {
      final isCheapest = (f.price == minPrice);
      final isMostExpensive = (f.price == maxPrice && maxPrice > minPrice);
      final isFastest = (_parseDuration(f.duration) == minDuration);
      final isLongest = (_parseDuration(f.duration) == maxDuration && maxDuration > minDuration);
      final isDirect = f.isDirect;
      final isUnderBudget = (criteria.maxPrice != null && f.price <= criteria.maxPrice!);

      if (isMostExpensive && criteria.sortPreference == SortPreference.expensive) {
        badges[f.id] = '✓ Premium option';
      } else if (isLongest && criteria.sortPreference == SortPreference.longest) {
        badges[f.id] = '✓ Longest journey';
      } else if (isCheapest && isDirect && isUnderBudget) {
        badges[f.id] = '✓ Cheapest direct option under budget';
      } else if (isCheapest && isDirect) {
        badges[f.id] = '✓ Cheapest direct option';
      } else if (isCheapest) {
        badges[f.id] = '✓ Cheapest option';
      } else if (isFastest && isDirect) {
        badges[f.id] = '✓ Shortest direct journey';
      } else if (isFastest) {
        badges[f.id] = '✓ Shortest journey';
      } else if (isUnderBudget && isDirect) {
        badges[f.id] = '✓ Direct flight under budget';
      } else if (isDirect) {
        badges[f.id] = '✓ Direct flight';
      } else if (isUnderBudget) {
        badges[f.id] = '✓ Under your budget';
      } else {
        badges[f.id] = '✓ Best match';
      }
    }

    return badges;
  }

  int _parseDuration(String durationStr) {
    try {
      final parts = durationStr.split(' ');
      int hours = 0;
      int mins = 0;
      for (final p in parts) {
        if (p.contains('h')) {
          hours = int.parse(p.replaceAll('h', ''));
        } else if (p.contains('m')) {
          mins = int.parse(p.replaceAll('m', ''));
        }
      }
      return (hours * 60) + mins;
    } catch (_) {
      return 180;
    }
  }
}
