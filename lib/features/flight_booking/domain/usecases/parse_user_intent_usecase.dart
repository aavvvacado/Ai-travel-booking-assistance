import '../../../../core/errors/result.dart';
import '../../../../core/services/ai_service.dart';
import '../entities/search_criteria.dart';
import '../repositories/flight_repository.dart';

class ParseUserIntentUseCase {
  final AiService aiService;
  final FlightRepository flightRepository;

  ParseUserIntentUseCase({
    required this.aiService,
    required this.flightRepository,
  });

  Future<Result<AiResult>> call({
    required String userPrompt,
    required SearchCriteria currentCriteria,
    String? lastExpectedParameter,
  }) async {
    final flightsResult = await flightRepository.getAllFlights();
    final availableFlights = flightsResult.dataOrNull ?? [];

    return aiService.parseUserPrompt(
      userPrompt: userPrompt,
      currentCriteria: currentCriteria,
      availableFlights: availableFlights,
      lastExpectedParameter: lastExpectedParameter,
    );
  }
}
