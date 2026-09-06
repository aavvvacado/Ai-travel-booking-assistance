import 'stt_service.dart';
import 'tts_service.dart';
import 'ai_service.dart';
import '../constants/api_constants.dart';
import '../../features/flight_booking/data/datasources/flight_local_datasource.dart';
import '../../features/flight_booking/data/datasources/booking_local_datasource.dart';
import '../../features/flight_booking/data/repositories/flight_repository_impl.dart';
import '../../features/flight_booking/data/repositories/booking_repository_impl.dart';
import '../../features/flight_booking/domain/repositories/flight_repository.dart';
import '../../features/flight_booking/domain/repositories/booking_repository.dart';
import '../../features/flight_booking/domain/usecases/parse_user_intent_usecase.dart';
import '../../features/flight_booking/domain/usecases/search_flights_usecase.dart';
import '../../features/flight_booking/domain/usecases/confirm_booking_usecase.dart';
import '../../features/flight_booking/domain/usecases/cancel_booking_usecase.dart';
import '../utils/date_resolver.dart';
import '../../features/flight_booking/domain/services/flight_search_service.dart';
import '../../features/flight_booking/domain/services/mock_booking_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  // Core Services
  late final SttService sttService;
  late final TtsService ttsService;
  late final AiService aiService;
  late final DateResolver dateResolver;
  late final FlightSearchService flightSearchService;
  late final MockBookingService mockBookingService;

  // Data Sources
  late final FlightLocalDataSource flightLocalDataSource;
  late final BookingLocalDataSource bookingLocalDataSource;

  // Repositories
  late final FlightRepository flightRepository;
  late final BookingRepository bookingRepository;

  // Use Cases
  late final ParseUserIntentUseCase parseUserIntentUseCase;
  late final SearchFlightsUseCase searchFlightsUseCase;
  late final ConfirmBookingUseCase confirmBookingUseCase;
  late final CancelBookingUseCase cancelBookingUseCase;

  void init() {
    // 1. Core Services
    sttService = SpeechToTextServiceImpl();
    ttsService = FlutterTtsServiceImpl();
    aiService = HybridAiServiceImpl()
      ..setApiKey(ApiConstants.defaultGeminiApiKey);
    dateResolver = const DateResolver();
    flightSearchService = const FlightSearchService();
    mockBookingService = const MockBookingService();

    // 2. Data Sources
    flightLocalDataSource = FlightLocalDataSourceImpl();
    bookingLocalDataSource = BookingLocalDataSourceImpl();

    // 3. Repositories
    flightRepository = FlightRepositoryImpl(flightLocalDataSource);
    bookingRepository = BookingRepositoryImpl(bookingLocalDataSource);

    // 4. Use Cases
    parseUserIntentUseCase = ParseUserIntentUseCase(
      aiService: aiService,
      flightRepository: flightRepository,
    );
    searchFlightsUseCase = SearchFlightsUseCase(flightRepository);
    confirmBookingUseCase = ConfirmBookingUseCase(bookingRepository);
    cancelBookingUseCase = CancelBookingUseCase(bookingRepository);
  }
}
