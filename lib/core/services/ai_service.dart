import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/flight_booking/domain/entities/search_criteria.dart';
import '../../features/flight_booking/domain/entities/flight.dart';
import '../../features/flight_booking/domain/entities/travel_date_preference.dart';
import '../../features/flight_booking/domain/services/flight_search_service.dart';
import '../utils/date_resolver.dart';
import '../errors/result.dart';

enum AiAction {
  greeting,
  askClarification,
  searchFlights,
  confirmBooking,
  completeBooking,
  cancelBooking,
}

class AiResult {
  final AiAction action;
  final SearchCriteria updatedCriteria;
  final String conversationalResponse;
  final String? reasoning;
  final List<String> missingParameters;
  final bool isBookingConfirmationRequest;
  final String? flightNumberToBook;
  final int? flightIndexToBook;
  final List<Flight> matchingFlights;
  final Map<String, String> smartBadges;
  final String? lastExpectedParameter;

  AiResult({
    required this.action,
    required this.updatedCriteria,
    required this.conversationalResponse,
    this.reasoning,
    this.missingParameters = const [],
    this.isBookingConfirmationRequest = false,
    this.flightNumberToBook,
    this.flightIndexToBook,
    this.matchingFlights = const [],
    this.smartBadges = const {},
    this.lastExpectedParameter,
  });
}

abstract class AiService {
  Future<Result<AiResult>> parseUserPrompt({
    required String userPrompt,
    required SearchCriteria currentCriteria,
    required List<Flight> availableFlights,
    String? lastExpectedParameter,
  });

  void setApiKey(String? apiKey);
  String? get apiKey;
}

const String kSystemPrompt = r"""
You are an AI Travel Booking Assistant inside a mobile flight-booking application.
Application Context:
CURRENT_DATE: 2026-09-06
CURRENT_TIMEZONE: Asia/Kolkata

Your job is to have a natural, friendly conversation, understand travel requirements, maintain conversation context, handle date corrections, and output exact structured JSON.

==================================================
RULES
==================================================
1. PRESERVE CONVERSATION STATE: Keep existing confirmed origin, destination, maxPrice, directOnly, datePreference across turns unless explicitly changed or corrected.
2. DATE EXPRESSIONS:
   - "next weekend" = date range Saturday to Sunday (Sep 12-13 relative to 2026-09-06).
   - "next week" = date range Monday to Sunday (Sep 7-13).
   - "tomorrow" = 2026-09-07.
   - "next Saturday" = Saturday Sep 12.
   - USER CORRECTION OVERRIDE: If user says "No, I said next week not 6 September", discard previous date and use next week.
3. SHORT ANSWERS: If asked "What date would you like to travel?", user answers "Tomorrow", set departure_date = "tomorrow".
4. SELECTION / BOOKING:
   - "book the first one" / "the second one" -> user is selecting a flight from search results.
   - "cancel" / "dont book" -> action: CANCEL_BOOKING.
5. MANDATORY FIELDS for search: origin, destination, departure_date.
6. OUTPUT: Return ONLY valid JSON. No markdown fences.

8. EXPLAIN MATCHES & HELP THE USER CHOOSE:
- Act as a travel advisor, not just a search-results narrator.
- After flight search, identify the strongest options based on the user's preferences and explain the key trade-offs in `spoken_response`.
- First prioritize explicit user constraints. If the user said "cheapest direct flight under $200", prioritize those requirements over general notions of convenience.
- If the user has no strict preference, compare meaningful dimensions such as:
  1. lowest price
  2. shortest total travel time
  3. non-stop vs. connecting
  4. shortest layover
  5. departure/arrival convenience
  6. overall value
- When appropriate, present 2–3 useful choices using natural language such as:
  "The cheapest option is $175, the fastest is $20 more and non-stop, while another option leaves later if you prefer a more convenient departure."
- Do not overwhelm the user with every result. Highlight only the differences that could help them make a decision.
- If one option clearly satisfies the user's stated requirements better than the others, call it the "best match" and explain why.
- If there is no clear winner, do not force a recommendation. Present the relevant trade-offs instead.
- Never invent or estimate flight attributes. Every comparison must be derived from the actual flight results supplied by the application.
- Detailed flight information, timings, prices, and metadata should be displayed in the UI. `spoken_response` should provide only a concise conversational summary suitable for TTS.

JSON Format:
{
  "action": "GREETING | ASK_CLARIFICATION | SEARCH_FLIGHTS | CONFIRM_BOOKING | CANCEL_BOOKING",
  "spoken_response": "Short natural response explaining the matches (1-2 sentences)",
  "parameters": {
    "origin": "string or null",
    "destination": "string or null",
    "departure_date": "string or null",
    "max_price": "integer or null",
    "max_duration": "integer or null (in minutes)",
    "direct_only": "boolean or null",
    "sort_preference": "CHEAPEST | EXPENSIVE | FASTEST | LONGEST | EARLIEST | LATEST | NONE or null",
    "selected_flight_index": "integer or null"
  },
  "missing_parameters": [],
  "expected_parameter": "string or null"
}
""";

/// Rule-Based NLP & DateResolver Service
class LocalRuleAiServiceImpl implements AiService {
  final DateResolver _dateResolver = const DateResolver();
  final FlightSearchService _searchService = const FlightSearchService();

  @override
  String? apiKey;

  static const Map<String, String> cityMap = {
    'mumbai': 'Mumbai',
    'bom': 'Mumbai',
    'dubai': 'Dubai',
    'dxb': 'Dubai',
    'delhi': 'Delhi',
    'new delhi': 'Delhi',
    'del': 'Delhi',
    'singapore': 'Singapore',
    'sin': 'Singapore',
    'london': 'London',
    'lhr': 'London',
    'new york': 'New York',
    'nyc': 'New York',
    'jfk': 'New York',
    'tokyo': 'Tokyo',
    'hnd': 'Tokyo',
    'nrt': 'Tokyo',
    'san francisco': 'San Francisco',
    'sfo': 'San Francisco',
    'chennai': 'Chennai',
    'maa': 'Chennai',
    'bengaluru': 'Bengaluru',
    'bangalore': 'Bengaluru',
    'blr': 'Bengaluru',
  };

  @override
  void setApiKey(String? key) {
    apiKey = key;
  }

  String _sanitizeInput(String raw) {
    return raw
        .replaceAll(
          RegExp(
            r'^(?:hi|hello|hey|hii|please|can you|could you|i want to|i need to|find me|search|check|look for|show me|book a|book)\s+',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
  }

  String? _resolveCity(String raw) {
    if (raw.trim().isEmpty) return null;
    final lowerRaw = raw.toLowerCase().trim();

    for (final entry in cityMap.entries) {
      final key = entry.key;
      final regex = RegExp('\\b${RegExp.escape(key)}\\b', caseSensitive: false);
      if (regex.hasMatch(lowerRaw)) {
        return entry.value;
      }
    }
    return null;
  }

  @override
  Future<Result<AiResult>> parseUserPrompt({
    required String userPrompt,
    required SearchCriteria currentCriteria,
    required List<Flight> availableFlights,
    String? lastExpectedParameter,
  }) async {
    final text = userPrompt.toLowerCase().trim();
    final sanitizedText = _sanitizeInput(userPrompt);

    // 1. Check for Cancellation Intent
    if (text.contains('cancel booking') ||
        text.contains('cancel ticket') ||
        text.contains("don't book") ||
        text.contains("dont book") ||
        text.contains('never mind') ||
        text.contains('forget it') ||
        text.contains('stop booking') ||
        text.contains("actually don't book")) {
      return Success(
        AiResult(
          action: AiAction.cancelBooking,
          updatedCriteria: currentCriteria,
          conversationalResponse: "Booking request cancelled. What else can I help you with?",
        ),
      );
    }

    // 2. Check for Greeting
    if (text == 'hi' || text == 'hello' || text == 'hey' || text == 'hii' || text == 'hey there') {
      return Success(
        AiResult(
          action: AiAction.greeting,
          updatedCriteria: currentCriteria,
          conversationalResponse: "Hello! I am your AI Travel Assistant. Where would you like to fly today?",
          missingParameters: ['origin', 'destination', 'departure_date'],
          lastExpectedParameter: 'origin',
        ),
      );
    }

    // 3. Selection / Booking Intent
    int? flightIndexToBook;
    if (text.contains('first one') || text.contains('1st one') || text.contains('the first flight')) {
      flightIndexToBook = 0;
    } else if (text.contains('second one') || text.contains('2nd one') || text.contains('the second flight')) {
      flightIndexToBook = 1;
    } else if (text.contains('third one') || text.contains('3rd one') || text.contains('the third flight')) {
      flightIndexToBook = 2;
    }

    if (flightIndexToBook != null ||
        text.contains('book it') ||
        text.contains('confirm booking') ||
        text.contains('proceed with booking') ||
        text.contains('yes book')) {
      return Success(
        AiResult(
          action: AiAction.confirmBooking,
          updatedCriteria: currentCriteria,
          conversationalResponse: "I have selected your flight and prepared the details for review.",
          isBookingConfirmationRequest: true,
          flightIndexToBook: flightIndexToBook,
        ),
      );
    }

    // 4. State Merging - Start with current criteria
    String? newOrigin = currentCriteria.origin;
    String? newDest = currentCriteria.destination;
    TravelDatePreference? newDatePref = currentCriteria.datePreference;
    double? newMaxPrice = currentCriteria.maxPrice;
    int? newMaxDuration = currentCriteria.maxDuration;
    bool? newDirectOnly = currentCriteria.directOnly;
    SortPreference newSort = currentCriteria.sortPreference;

    // Price budget parsing
    final priceMatch = RegExp(
      r'(?:under|below|less than|budget|price|around|\$|₹)\s*(?:rs|inr|\$|₹)?\s*(\d{1,3}(?:,\d{3})*|\d+)\s*(k|thousand)?',
      caseSensitive: false,
    ).firstMatch(text);

    if (priceMatch != null) {
      final rawNumStr = priceMatch.group(1)!.replaceAll(',', '');
      double val = double.tryParse(rawNumStr) ?? 0.0;
      if (priceMatch.group(2)?.toLowerCase() == 'k') {
        val *= 1000;
      }
      if (val > 0) newMaxPrice = val;
    }

    // Direct / Non-stop preferences
    if (text.contains('no layover') ||
        text.contains('direct flight') ||
        text.contains('direct') ||
        text.contains('non-stop') ||
        text.contains("don't want a connecting") ||
        text.contains("no connecting")) {
      newDirectOnly = true;
    } else if (text.contains("don't want a long layover") ||
        text.contains("no long layover") ||
        text.contains("short layover")) {
      newDirectOnly = false;
      newMaxDuration = 400; // max ~6.5h total duration
    } else if (text.contains('connecting is fine') ||
        text.contains('any flight') ||
        text.contains('allow layover')) {
      newDirectOnly = false;
    }

    // Sort preferences: cheapest, fastest, expensive, longest, earliest, latest
    if (text.contains('cheapest') || text.contains('lowest fare') || text.contains('budget option')) {
      newSort = SortPreference.cheapest;
    } else if (text.contains('expensive') || text.contains('premium') || text.contains('most expensive') || text.contains('costliest') || text.contains('highest fare')) {
      newSort = SortPreference.expensive;
    } else if (text.contains('fastest') || text.contains('shortest') || text.contains('quickest')) {
      newSort = SortPreference.fastest;
    } else if (text.contains('longest') || text.contains('most duration')) {
      newSort = SortPreference.longest;
    } else if (text.contains('earliest') || text.contains('morning flight')) {
      newSort = SortPreference.earliest;
    } else if (text.contains('latest') || text.contains('evening flight') || text.contains('night flight')) {
      newSort = SortPreference.latest;
    }

    // 5. Date Parsing & Date Correction Handling
    bool isDateCorrection = text.contains('i said') ||
        text.contains('no, i said') ||
        text.contains('after the 12th') ||
        text.contains('after 12th') ||
        text.contains('after 12 sep');

    DateTime? anchorDate;
    if (isDateCorrection && currentCriteria.datePreference?.startDate != null) {
      anchorDate = currentCriteria.datePreference!.startDate;
    }

    // If context expected a date or prompt contains date words
    if (lastExpectedParameter == 'departure_date' ||
        isDateCorrection ||
        text.contains('weekend') ||
        text.contains('tomorrow') ||
        text.contains('today') ||
        text.contains('saturday') ||
        text.contains('sunday') ||
        text.contains('monday') ||
        text.contains('tuesday') ||
        text.contains('wednesday') ||
        text.contains('thursday') ||
        text.contains('friday') ||
        text.contains('next week') ||
        text.contains('this week') ||
        RegExp(r'\d{1,2}(?:st|nd|rd|th)?\s+(?:sep|oct|nov|dec|jan|feb|mar|apr|may|jun|jul)').hasMatch(text)) {
      final resolved = _dateResolver.resolve(
        userPrompt,
        referenceDate: DateResolver.defaultNow,
        anchorDate: anchorDate,
      );
      newDatePref = resolved;
    }

    // 6. City / Route Parsing
    String? parsedOrigin;
    String? parsedDest;

    final fromToPattern = RegExp(r'\bfrom\s+([a-zA-Z\s]+?)\s+\bto\s+([a-zA-Z\s]+)', caseSensitive: false);
    final fromToMatch = fromToPattern.firstMatch(sanitizedText);

    if (fromToMatch != null) {
      parsedOrigin = _resolveCity(fromToMatch.group(1)!);
      parsedDest = _resolveCity(fromToMatch.group(2)!);
    } else {
      final toPattern = RegExp(r'\b([a-zA-Z\s]+?)\s+(?:to|towards|->)\s+([a-zA-Z\s]+)', caseSensitive: false);
      final toMatch = toPattern.firstMatch(sanitizedText);
      if (toMatch != null) {
        parsedOrigin = _resolveCity(toMatch.group(1)!);
        parsedDest = _resolveCity(toMatch.group(2)!);
      }
    }

    if (parsedOrigin != null) newOrigin = parsedOrigin;
    if (parsedDest != null) newDest = parsedDest;

    if (parsedOrigin == null && parsedDest == null) {
      for (var entry in cityMap.entries) {
        final key = entry.key;
        final city = entry.value;

        if (text.contains(key)) {
          if (text.contains('from $key') || text.contains('leaving $key') || text.contains('departing $key')) {
            newOrigin = city;
          } else if (text.contains('to $key') || text.contains('towards $key') || text.contains('fly $key') || text.contains('flight to $key')) {
            newDest = city;
          } else if (lastExpectedParameter == 'origin') {
            newOrigin = city;
          } else if (lastExpectedParameter == 'destination') {
            newDest = city;
          }
        }
      }
    }

    // Default date preference to flexible if user specifies filtering/budget preferences without a specific date
    if (newDatePref == null &&
        (text.contains('cheapest') ||
            text.contains('fastest') ||
            text.contains('direct') ||
            newMaxPrice != null)) {
      newDatePref = TravelDatePreference.flexible(originalExpression: 'Flexible dates');
    }

    final updatedCriteria = currentCriteria.copyWith(
      origin: newOrigin,
      destination: newDest,
      datePreference: newDatePref,
      originalDateExpression: newDatePref?.originalExpression,
      maxPrice: newMaxPrice,
      maxDuration: newMaxDuration,
      directOnly: newDirectOnly,
      sortPreference: newSort,
    );

    // 7. Check Missing Mandatory Parameters
    final missing = <String>[];
    String? nextExpectedParam;

    if (updatedCriteria.origin == null || updatedCriteria.origin!.trim().isEmpty) {
      missing.add('origin');
      nextExpectedParam = 'origin';
    }
    if (updatedCriteria.destination == null || updatedCriteria.destination!.trim().isEmpty) {
      missing.add('destination');
      nextExpectedParam ??= 'destination';
    }
    if (updatedCriteria.datePreference == null) {
      missing.add('departure_date');
      nextExpectedParam ??= 'departure_date';
    }

    if (missing.isNotEmpty) {
      String responseStr;
      if (updatedCriteria.origin == null && updatedCriteria.destination == null) {
        responseStr = "Where would you like to fly from and to?";
      } else if (updatedCriteria.origin == null) {
        responseStr = "Which departure city will you be flying from for your trip to ${updatedCriteria.destination}?";
      } else if (updatedCriteria.destination == null) {
        responseStr = "Where would you like to fly to from ${updatedCriteria.origin}?";
      } else {
        responseStr = "What date would you like to travel from ${updatedCriteria.origin} to ${updatedCriteria.destination}?";
      }

      return Success(
        AiResult(
          action: AiAction.askClarification,
          updatedCriteria: updatedCriteria,
          conversationalResponse: responseStr,
          missingParameters: missing,
          lastExpectedParameter: nextExpectedParam,
        ),
      );
    }

    // 8. Search flights deterministically via FlightSearchService
    List<Flight> matching = _searchService.searchFlights(
      flights: availableFlights,
      criteria: updatedCriteria,
    );

    final smartBadges = _searchService.generateSmartBadges(
      results: matching,
      criteria: updatedCriteria,
    );

    String spokenText;
    if (matching.isEmpty) {
      spokenText = "I couldn't find any flights matching your criteria for ${updatedCriteria.origin} to ${updatedCriteria.destination}. Would you like to adjust your travel dates or budget?";
    } else {
      String explanation = "";
      if (updatedCriteria.maxPrice != null && updatedCriteria.maxDuration != null) {
        explanation = " Prioritizing the cheapest options with short layovers.";
      } else if (updatedCriteria.maxDuration != null) {
        explanation = " Prioritizing flights with short layovers as requested.";
      } else if (updatedCriteria.sortPreference == SortPreference.expensive) {
        explanation = " Prioritizing the most premium and expensive options as requested.";
      } else if (updatedCriteria.sortPreference == SortPreference.longest) {
        explanation = " Prioritizing the longest journeys.";
      } else if (updatedCriteria.maxPrice != null) {
        explanation = " Prioritizing flights under your budget.";
      }
      spokenText = "I found ${matching.length} flight option${matching.length > 1 ? 's' : ''} from ${updatedCriteria.origin} to ${updatedCriteria.destination} for ${updatedCriteria.dateText ?? 'your date'}.$explanation Here are the best matches.";
    }

    return Success(
      AiResult(
        action: AiAction.searchFlights,
        updatedCriteria: updatedCriteria,
        conversationalResponse: spokenText,
        matchingFlights: matching,
        smartBadges: smartBadges,
      ),
    );
  }
}

/// Hybrid Gemini LLM AI Service
class HybridAiServiceImpl implements AiService {
  final LocalRuleAiServiceImpl _localService = LocalRuleAiServiceImpl();
  GenerativeModel? _model;
  ChatSession? _chatSession;

  @override
  String? apiKey;

  @override
  void setApiKey(String? key) {
    apiKey = key;
    if (key != null && key.trim().isNotEmpty && !key.startsWith('AQ.')) {
      try {
        _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: key.trim(),
          systemInstruction: Content.system(kSystemPrompt),
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            temperature: 0.2,
          ),
        );
        _chatSession = _model!.startChat();
      } catch (_) {
        _model = null;
        _chatSession = null;
      }
    } else {
      _model = null;
      _chatSession = null;
    }
  }

  @override
  Future<Result<AiResult>> parseUserPrompt({
    required String userPrompt,
    required SearchCriteria currentCriteria,
    required List<Flight> availableFlights,
    String? lastExpectedParameter,
  }) async {
    // If no active chat session or online call fails, use rule-based service seamlessly
    if (_chatSession == null) {
      return _localService.parseUserPrompt(
        userPrompt: userPrompt,
        currentCriteria: currentCriteria,
        availableFlights: availableFlights,
        lastExpectedParameter: lastExpectedParameter,
      );
    }

    try {
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

      final response = await _chatSession!.sendMessage(Content.text(userMessage));
      final rawJson = response.text;

      if (rawJson != null && rawJson.isNotEmpty) {
        final map = jsonDecode(rawJson) as Map<String, dynamic>;
        final params = map['parameters'] as Map<String, dynamic>? ?? {};

        final actionStr = (map['action'] as String? ?? 'SEARCH_FLIGHTS').toUpperCase();
        AiAction action = AiAction.searchFlights;
        if (actionStr == 'GREETING') action = AiAction.greeting;
        if (actionStr == 'ASK_CLARIFICATION') action = AiAction.askClarification;
        if (actionStr == 'CONFIRM_BOOKING') action = AiAction.confirmBooking;
        if (actionStr == 'CANCEL_BOOKING') action = AiAction.cancelBooking;

        String? origin = params['origin'];
        String? destination = params['destination'];
        String? dateStr = params['departure_date'];

        if (origin != null && origin.toLowerCase() != 'null') {
          origin = _localService._resolveCity(origin);
        } else {
          origin = currentCriteria.origin;
        }

        if (destination != null && destination.toLowerCase() != 'null') {
          destination = _localService._resolveCity(destination);
        } else {
          destination = currentCriteria.destination;
        }

        TravelDatePreference? datePref = currentCriteria.datePreference;
        if (dateStr != null && dateStr != 'null' && dateStr.isNotEmpty) {
          datePref = const DateResolver().resolve(
            dateStr,
            referenceDate: DateResolver.defaultNow,
            anchorDate: currentCriteria.datePreference?.startDate,
          );
        }

        SortPreference? sortPref = currentCriteria.sortPreference;
        if (params['sort_preference'] != null) {
          final sp = params['sort_preference'].toString().toUpperCase();
          if (sp == 'CHEAPEST') sortPref = SortPreference.cheapest;
          else if (sp == 'EXPENSIVE') sortPref = SortPreference.expensive;
          else if (sp == 'FASTEST') sortPref = SortPreference.fastest;
          else if (sp == 'LONGEST') sortPref = SortPreference.longest;
          else if (sp == 'EARLIEST') sortPref = SortPreference.earliest;
          else if (sp == 'LATEST') sortPref = SortPreference.latest;
          else if (sp == 'NONE') sortPref = SortPreference.none;
        }

        final updated = currentCriteria.copyWith(
          origin: origin,
          destination: destination,
          datePreference: datePref,
          originalDateExpression: datePref?.originalExpression ?? dateStr,
          maxPrice: params['max_price'] != null ? (params['max_price'] as num).toDouble() : currentCriteria.maxPrice,
          maxDuration: params['max_duration'] != null ? (params['max_duration'] as num).toInt() : currentCriteria.maxDuration,
          directOnly: params['direct_only'] as bool? ?? currentCriteria.directOnly,
          sortPreference: sortPref,
        );

        final spokenResponse = map['spoken_response'] as String? ?? "Here are your flight search results.";
        final missingList = List<String>.from(map['missing_parameters'] ?? []);
        final nextExp = map['expected_parameter'] as String?;

        int? selectedIndex;
        if (params['selected_flight_index'] != null) {
          selectedIndex = (params['selected_flight_index'] as num).toInt();
        }

        final matching = const FlightSearchService().searchFlights(
          flights: availableFlights,
          criteria: updated,
        );

        final smartBadges = const FlightSearchService().generateSmartBadges(
          results: matching,
          criteria: updated,
        );

        return Success(
          AiResult(
            action: action,
            updatedCriteria: updated,
            conversationalResponse: spokenResponse,
            missingParameters: missingList,
            isBookingConfirmationRequest: action == AiAction.confirmBooking,
            flightIndexToBook: selectedIndex,
            matchingFlights: matching,
            smartBadges: smartBadges,
            lastExpectedParameter: nextExp,
          ),
        );
      }
    } catch (_) {
      // Fallback seamlessly on network/API failure
    }

    return _localService.parseUserPrompt(
      userPrompt: userPrompt,
      currentCriteria: currentCriteria,
      availableFlights: availableFlights,
      lastExpectedParameter: lastExpectedParameter,
    );
  }
}
