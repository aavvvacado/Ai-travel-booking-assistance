import 'package:flutter_test/flutter_test.dart';
import 'package:aitravelbookingassistance/features/flight_booking/domain/entities/search_criteria.dart';
import 'package:aitravelbookingassistance/features/flight_booking/domain/entities/travel_date_preference.dart';
import 'package:aitravelbookingassistance/features/flight_booking/data/datasources/flight_local_datasource.dart';
import 'package:aitravelbookingassistance/core/services/ai_service.dart';
import 'package:aitravelbookingassistance/core/utils/date_resolver.dart';

void main() {
  late FlightLocalDataSourceImpl localDataSource;
  late LocalRuleAiServiceImpl aiService;
  final dateResolver = const DateResolver();

  setUp(() {
    localDataSource = FlightLocalDataSourceImpl();
    aiService = LocalRuleAiServiceImpl();
  });

  group('DateResolver Tests', () {
    final refDate = DateTime(2026, 9, 6); // Sunday Sep 6, 2026

    test('resolves "next weekend" to date range Saturday (Sep 12) - Sunday (Sep 13)', () {
      final pref = dateResolver.resolve('next weekend', referenceDate: refDate);
      expect(pref.type, DatePreferenceType.dateRange);
      expect(pref.startDate, DateTime(2026, 9, 12));
      expect(pref.endDate, DateTime(2026, 9, 13));
    });

    test('resolves "tomorrow" to Sep 7', () {
      final pref = dateResolver.resolve('tomorrow', referenceDate: refDate);
      expect(pref.startDate, DateTime(2026, 9, 7));
    });

    test('resolves date correction "next weekend after the 12th" to Sep 19-20', () {
      final anchor = DateTime(2026, 9, 12);
      final pref = dateResolver.resolve(
        'next weekend after the 12th',
        referenceDate: refDate,
        anchorDate: anchor,
      );
      expect(pref.type, DatePreferenceType.dateRange);
      expect(pref.startDate, DateTime(2026, 9, 19));
      expect(pref.endDate, DateTime(2026, 9, 20));
    });
  });

  group('Requirement 30 Test Conversations (TEST A - G)', () {
    test('TEST A: Ask clarification for missing date -> Short answer "Tomorrow" populates date', () async {
      final flights = await localDataSource.getFlights();

      // Step 1: User says "Find me a flight from Delhi to Dubai."
      final res1 = await aiService.parseUserPrompt(
        userPrompt: 'Find me a flight from Delhi to Dubai.',
        currentCriteria: const SearchCriteria(),
        availableFlights: flights,
      );

      final data1 = res1.dataOrNull!;
      expect(data1.action, AiAction.askClarification);
      expect(data1.updatedCriteria.origin, 'Delhi');
      expect(data1.updatedCriteria.destination, 'Dubai');
      expect(data1.lastExpectedParameter, 'departure_date');

      // Step 2: User responds "Tomorrow."
      final res2 = await aiService.parseUserPrompt(
        userPrompt: 'Tomorrow.',
        currentCriteria: data1.updatedCriteria,
        availableFlights: flights,
        lastExpectedParameter: data1.lastExpectedParameter,
      );

      final data2 = res2.dataOrNull!;
      expect(data2.action, AiAction.searchFlights);
      expect(data2.updatedCriteria.datePreference != null, true);
      expect(data2.updatedCriteria.origin, 'Delhi');
      expect(data2.updatedCriteria.destination, 'Dubai');
    });

    test('TEST B: "Delhi to Dubai next weekend." represents next weekend date range', () async {
      final flights = await localDataSource.getFlights();
      final res = await aiService.parseUserPrompt(
        userPrompt: 'Delhi to Dubai next weekend.',
        currentCriteria: const SearchCriteria(),
        availableFlights: flights,
      );

      final data = res.dataOrNull!;
      expect(data.action, AiAction.searchFlights);
      expect(data.updatedCriteria.datePreference?.isRange, true);
      expect(data.updatedCriteria.datePreference?.startDate, DateTime(2026, 9, 12));
      expect(data.updatedCriteria.datePreference?.endDate, DateTime(2026, 9, 13));
    });

    test('TEST C: User date correction overrides previous date interpretation', () async {
      final flights = await localDataSource.getFlights();

      // Previous state had Sep 12 (12th September)
      final initialCriteria = SearchCriteria(
        origin: 'Delhi',
        destination: 'Dubai',
        datePreference: TravelDatePreference.exact(
          DateTime(2026, 9, 12),
          originalExpression: '12 Sep',
        ),
      );

      // User says: "No, I said next weekend after the 12th."
      final res = await aiService.parseUserPrompt(
        userPrompt: 'No, I said next weekend after the 12th.',
        currentCriteria: initialCriteria,
        availableFlights: flights,
      );

      final data = res.dataOrNull!;
      expect(data.action, AiAction.searchFlights);
      expect(data.updatedCriteria.datePreference?.startDate, DateTime(2026, 9, 19));
      expect(data.updatedCriteria.datePreference?.endDate, DateTime(2026, 9, 20));
    });

    test('TEST D: "The second one" selects second search result option', () async {
      final flights = await localDataSource.getFlights();
      const current = SearchCriteria(origin: 'Delhi', destination: 'Dubai');

      final res = await aiService.parseUserPrompt(
        userPrompt: 'The second one.',
        currentCriteria: current,
        availableFlights: flights,
      );

      final data = res.dataOrNull!;
      expect(data.action, AiAction.confirmBooking);
      expect(data.flightIndexToBook, 1); // 2nd item is index 1
    });

    test('TEST E: "Book it." triggers booking confirmation action', () async {
      final flights = await localDataSource.getFlights();
      const current = SearchCriteria(origin: 'Delhi', destination: 'Dubai');

      final res = await aiService.parseUserPrompt(
        userPrompt: 'Book it.',
        currentCriteria: current,
        availableFlights: flights,
      );

      final data = res.dataOrNull!;
      expect(data.action, AiAction.confirmBooking);
      expect(data.isBookingConfirmationRequest, true);
    });

    test('TEST F: "Actually don\'t book it." triggers cancel booking action', () async {
      final flights = await localDataSource.getFlights();
      const current = SearchCriteria(origin: 'Delhi', destination: 'Dubai');

      final res = await aiService.parseUserPrompt(
        userPrompt: "Actually don't book it.",
        currentCriteria: current,
        availableFlights: flights,
      );

      final data = res.dataOrNull!;
      expect(data.action, AiAction.cancelBooking);
    });

    test('TEST G: "I want the cheapest direct flight under 20k." filters & sorts deterministically', () async {
      final flights = await localDataSource.getFlights();

      final res = await aiService.parseUserPrompt(
        userPrompt: 'Delhi to Dubai cheapest direct flight under 20k.',
        currentCriteria: const SearchCriteria(),
        availableFlights: flights,
      );

      final data = res.dataOrNull!;
      expect(data.action, AiAction.searchFlights);
      expect(data.updatedCriteria.directOnly, true);
      expect(data.updatedCriteria.maxPrice, 20000.0);
      expect(data.updatedCriteria.sortPreference, SortPreference.cheapest);

      final matching = data.matchingFlights;
      expect(matching.isNotEmpty, true);
      expect(matching.every((f) => f.isDirect && f.price <= 20000.0), true);
    });
  });
}
