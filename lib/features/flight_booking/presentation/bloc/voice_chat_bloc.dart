import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/stt_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/flight.dart';
import '../../domain/entities/passenger_details.dart';
import '../../domain/entities/search_criteria.dart';
import '../../domain/services/flight_search_service.dart';
import '../../domain/services/mock_booking_service.dart';
import '../../domain/usecases/parse_user_intent_usecase.dart';
import '../../domain/usecases/search_flights_usecase.dart';
import 'voice_chat_event.dart';
import 'voice_chat_state.dart';

class VoiceChatBloc extends Bloc<VoiceChatEvent, VoiceChatState> {
  final SttService sttService;
  final TtsService ttsService;
  final ParseUserIntentUseCase parseUserIntentUseCase;
  final SearchFlightsUseCase searchFlightsUseCase;
  final MockBookingService mockBookingService = const MockBookingService();

  VoiceChatBloc({
    required this.sttService,
    required this.ttsService,
    required this.parseUserIntentUseCase,
    required this.searchFlightsUseCase,
  }) : super(const VoiceChatState()) {
    on<InitVoiceChatEvent>(_onInit);
    on<StartListeningEvent>(_onStartListening);
    on<StopListeningEvent>(_onStopListening);
    on<CancelListeningEvent>(_onCancelListening);
    on<SpeechRecognizedEvent>(_onSpeechRecognized);
    on<SendTextMessageEvent>(_onSendTextMessage);
    on<UpdateCriteriaEvent>(_onUpdateCriteria);
    on<ClearCriteriaEvent>(_onClearCriteria);
    on<ToggleMuteTtsEvent>(_onToggleMuteTts);
    on<SetGeminiApiKeyEvent>(_onSetGeminiApiKey);
    on<SelectFlightForBookingEvent>(_onSelectFlightForBooking);
    on<SetBookingStepEvent>(_onSetBookingStep);
    on<UpdatePassengerDetailsEvent>(_onUpdatePassengerDetails);
    on<ConfirmSelectedBookingEvent>(_onConfirmSelectedBooking);
    on<CancelCurrentBookingFlowEvent>(_onCancelCurrentBookingFlow);

    ttsService.setCompletionHandler(() {
      add(const SpeechRecognizedEvent('')); // Resets status to idle
    });
  }

  void _onInit(InitVoiceChatEvent event, Emitter<VoiceChatState> emit) async {
    await sttService.initialize();

    const initialGreeting =
        "Hello! I am your AI Travel Assistant. Where would you like to fly today?";

    final welcomeMessage = ChatMessage(
      id: 'msg_welcome',
      text: initialGreeting,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    );

    emit(
      state.copyWith(
        messages: [welcomeMessage],
        voiceStatus: VoiceStateStatus.speaking,
      ),
    );
  }

  void _onStartListening(
    StartListeningEvent event,
    Emitter<VoiceChatState> emit,
  ) async {
    if (state.isListening) {
      await sttService.stopListening();
      emit(state.copyWith(voiceStatus: VoiceStateStatus.idle));
      return;
    }

    await ttsService.stop();

    emit(
      state.copyWith(
        voiceStatus: VoiceStateStatus.listening,
        partialRecognizedText: '',
        errorMessage: null,
      ),
    );

    final result = await sttService.startListening(
      onResult: (text) {
        if (text.isNotEmpty) {
          add(SpeechRecognizedEvent(text));
        }
      },
      onSoundLevelChange: () {},
      onStatus: (status) {},
      onError: () {
        add(CancelListeningEvent());
      },
    );

    result.fold((success) {}, (failure) {
      emit(
        state.copyWith(
          voiceStatus: VoiceStateStatus.idle,
          errorMessage: null,
        ),
      );
    });
  }

  void _onStopListening(
    StopListeningEvent event,
    Emitter<VoiceChatState> emit,
  ) async {
    await sttService.stopListening();
    if (state.partialRecognizedText != null &&
        state.partialRecognizedText!.isNotEmpty) {
      add(SendTextMessageEvent(state.partialRecognizedText!));
    } else {
      emit(state.copyWith(voiceStatus: VoiceStateStatus.idle));
    }
  }

  void _onCancelListening(
    CancelListeningEvent event,
    Emitter<VoiceChatState> emit,
  ) async {
    await sttService.stopListening();
    emit(
      state.copyWith(
        voiceStatus: VoiceStateStatus.idle,
        partialRecognizedText: '',
      ),
    );
  }

  void _onSpeechRecognized(
    SpeechRecognizedEvent event,
    Emitter<VoiceChatState> emit,
  ) {
    if (event.recognizedText.isEmpty) {
      emit(state.copyWith(voiceStatus: VoiceStateStatus.idle));
      return;
    }
    emit(state.copyWith(partialRecognizedText: event.recognizedText));
  }

  void _onSendTextMessage(
    SendTextMessageEvent event,
    Emitter<VoiceChatState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;

    await sttService.stopListening();
    await ttsService.stop();

    final userMsg = ChatMessage(
      id: 'msg_user_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMsg);

    emit(
      state.copyWith(
        messages: updatedMessages,
        voiceStatus: VoiceStateStatus.processing,
        partialRecognizedText: '',
      ),
    );

    final result = await parseUserIntentUseCase(
      userPrompt: text,
      currentCriteria: state.activeCriteria,
      lastExpectedParameter: state.lastExpectedParameter,
    );

    await result.fold(
      (aiResult) async {
        List<Flight> matchingFlights = state.matchingFlights;
        if (aiResult.action == AiAction.searchFlights ||
            aiResult.action == AiAction.confirmBooking ||
            aiResult.matchingFlights.isNotEmpty) {
          matchingFlights = aiResult.matchingFlights;
        }

        Flight? flightToBook = state.selectedFlightForBooking;
        BookingStep newBookingStep = state.bookingStep;

        if (aiResult.action == AiAction.cancelBooking) {
          flightToBook = null;
          newBookingStep = BookingStep.none;
        } else if (aiResult.isBookingConfirmationRequest || aiResult.flightIndexToBook != null) {
          if (aiResult.flightIndexToBook != null &&
              aiResult.flightIndexToBook! >= 0 &&
              aiResult.flightIndexToBook! < matchingFlights.length) {
            flightToBook = matchingFlights[aiResult.flightIndexToBook!];
          } else if (aiResult.flightNumberToBook != null) {
            flightToBook = matchingFlights.firstWhere(
              (f) => f.flightNumber.toLowerCase() == aiResult.flightNumberToBook!.toLowerCase(),
              orElse: () => matchingFlights.isNotEmpty ? matchingFlights.first : flightToBook!,
            );
          } else if (flightToBook == null && matchingFlights.isNotEmpty) {
            flightToBook = matchingFlights.first;
          }
          if (flightToBook != null) {
            await ttsService.stop();
            newBookingStep = BookingStep.flightDetails;
          }
        }

        final aiMsg = ChatMessage(
          id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
          text: aiResult.conversationalResponse,
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
          recommendedFlights: (aiResult.action == AiAction.searchFlights && matchingFlights.isNotEmpty)
              ? matchingFlights
              : null,
          activeCriteria: aiResult.updatedCriteria,
          reasoning: aiResult.reasoning,
          isBookingPrompt: aiResult.isBookingConfirmationRequest,
          selectedFlightForBooking: flightToBook,
        );

        final finalMessages = List<ChatMessage>.from(updatedMessages)..add(aiMsg);

        emit(
          state.copyWith(
            messages: finalMessages,
            activeCriteria: aiResult.updatedCriteria,
            matchingFlights: matchingFlights,
            smartBadges: aiResult.smartBadges,
            lastExpectedParameter: aiResult.lastExpectedParameter,
            voiceStatus: (newBookingStep != BookingStep.none) ? VoiceStateStatus.idle : VoiceStateStatus.speaking,
            selectedFlightForBooking: flightToBook,
            bookingStep: newBookingStep,
          ),
        );
      },
      (failure) async {
        final errorMsg = ChatMessage(
          id: 'msg_err_${DateTime.now().millisecondsSinceEpoch}',
          text: "I encountered an issue processing your request: ${failure.message}",
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        );

        emit(
          state.copyWith(
            messages: List<ChatMessage>.from(updatedMessages)..add(errorMsg),
            voiceStatus: VoiceStateStatus.idle,
          ),
        );
      },
    );
  }

  void _onUpdateCriteria(
    UpdateCriteriaEvent event,
    Emitter<VoiceChatState> emit,
  ) async {
    emit(state.copyWith(activeCriteria: event.criteria));
    final flightsResult = await searchFlightsUseCase(event.criteria);
    final flights = flightsResult.dataOrNull ?? [];
    final badges = const FlightSearchService().generateSmartBadges(results: flights, criteria: event.criteria);
    emit(state.copyWith(matchingFlights: flights, smartBadges: badges));
  }

  void _onClearCriteria(
    ClearCriteriaEvent event,
    Emitter<VoiceChatState> emit,
  ) {
    emit(
      state.copyWith(
        activeCriteria: const SearchCriteria(),
        matchingFlights: [],
        smartBadges: {},
        lastExpectedParameter: null,
        clearSelectedFlight: true,
        bookingStep: BookingStep.none,
      ),
    );
  }

  void _onToggleMuteTts(
    ToggleMuteTtsEvent event,
    Emitter<VoiceChatState> emit,
  ) async {
    final newMute = !state.isTtsMuted;
    await ttsService.setMuted(newMute);
    emit(state.copyWith(isTtsMuted: newMute));
  }

  void _onSetGeminiApiKey(
    SetGeminiApiKeyEvent event,
    Emitter<VoiceChatState> emit,
  ) {
    ServiceLocator.instance.aiService.setApiKey(event.apiKey);
    emit(state.copyWith(geminiApiKey: event.apiKey));
  }

  void _onSelectFlightForBooking(
    SelectFlightForBookingEvent event,
    Emitter<VoiceChatState> emit,
  ) async {
    await ttsService.stop(); // Stop TTS immediately when user selects a flight!
    emit(
      state.copyWith(
        voiceStatus: VoiceStateStatus.idle,
        selectedFlightForBooking: event.flight,
        bookingStep: BookingStep.flightDetails,
      ),
    );
  }

  void _onSetBookingStep(
    SetBookingStepEvent event,
    Emitter<VoiceChatState> emit,
  ) async {
    if (event.step != BookingStep.none) {
      await ttsService.stop();
    }
    emit(
      state.copyWith(
        voiceStatus: event.step != BookingStep.none ? VoiceStateStatus.idle : state.voiceStatus,
        bookingStep: event.step,
      ),
    );
  }

  void _onUpdatePassengerDetails(
    UpdatePassengerDetailsEvent event,
    Emitter<VoiceChatState> emit,
  ) {
    emit(state.copyWith(passengerDetails: event.details));
  }

  void _onConfirmSelectedBooking(
    ConfirmSelectedBookingEvent event,
    Emitter<VoiceChatState> emit,
  ) async {
    if (state.selectedFlightForBooking == null) return;

    await ttsService.stop();

    emit(
      state.copyWith(
        voiceStatus: VoiceStateStatus.idle,
        bookingStep: BookingStep.processing,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1000));

    final passenger = state.passengerDetails ??
        const PassengerDetails(
          fullName: 'Vishal Pratap Singh',
          email: 'vishal@example.com',
          phone: '+91 98765 43210',
        );

    final booking = mockBookingService.createBooking(
      flight: state.selectedFlightForBooking!,
      passenger: passenger,
    );

    final confirmMsg = ChatMessage(
      id: 'msg_confirm_${DateTime.now().millisecondsSinceEpoch}',
      text: "Congratulations! Flight ${booking.flight.flightNumber} to ${booking.flight.destination} is confirmed. Booking reference: ${booking.bookingId}.",
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<ChatMessage>.from(state.messages)..add(confirmMsg);

    emit(
      state.copyWith(
        messages: updatedMessages,
        bookingStep: BookingStep.confirmed,
        latestConfirmedBooking: booking,
        voiceStatus: VoiceStateStatus.idle,
      ),
    );
  }

  void _onCancelCurrentBookingFlow(
    CancelCurrentBookingFlowEvent event,
    Emitter<VoiceChatState> emit,
  ) async {
    await ttsService.stop();
    emit(
      state.copyWith(
        voiceStatus: VoiceStateStatus.idle,
        bookingStep: BookingStep.none,
        clearSelectedFlight: true,
      ),
    );
  }
}
