import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/flight.dart';
import '../../domain/entities/passenger_details.dart';
import '../../domain/entities/search_criteria.dart';

enum VoiceStateStatus { idle, listening, processing, speaking, error }

enum BookingStep { none, flightDetails, passengerInput, reviewBooking, processing, confirmed }

class VoiceChatState extends Equatable {
  final VoiceStateStatus voiceStatus;
  final List<ChatMessage> messages;
  final SearchCriteria activeCriteria;
  final List<Flight> matchingFlights;
  final Map<String, String> smartBadges;
  final String? lastExpectedParameter;
  final String? partialRecognizedText;
  final bool isTtsMuted;
  final String? geminiApiKey;
  final String? errorMessage;
  final Flight? selectedFlightForBooking;
  final PassengerDetails? passengerDetails;
  final BookingStep bookingStep;
  final Booking? latestConfirmedBooking;

  const VoiceChatState({
    this.voiceStatus = VoiceStateStatus.idle,
    this.messages = const [],
    this.activeCriteria = const SearchCriteria(),
    this.matchingFlights = const [],
    this.smartBadges = const {},
    this.lastExpectedParameter,
    this.partialRecognizedText,
    this.isTtsMuted = false,
    this.geminiApiKey,
    this.errorMessage,
    this.selectedFlightForBooking,
    this.passengerDetails,
    this.bookingStep = BookingStep.none,
    this.latestConfirmedBooking,
  });

  bool get isListening => voiceStatus == VoiceStateStatus.listening;
  bool get isProcessing => voiceStatus == VoiceStateStatus.processing;
  bool get isSpeaking => voiceStatus == VoiceStateStatus.speaking;

  VoiceChatState copyWith({
    VoiceStateStatus? voiceStatus,
    List<ChatMessage>? messages,
    SearchCriteria? activeCriteria,
    List<Flight>? matchingFlights,
    Map<String, String>? smartBadges,
    String? lastExpectedParameter,
    String? partialRecognizedText,
    bool? isTtsMuted,
    String? geminiApiKey,
    String? errorMessage,
    Flight? selectedFlightForBooking,
    PassengerDetails? passengerDetails,
    BookingStep? bookingStep,
    Booking? latestConfirmedBooking,
    bool clearSelectedFlight = false,
  }) {
    return VoiceChatState(
      voiceStatus: voiceStatus ?? this.voiceStatus,
      messages: messages ?? this.messages,
      activeCriteria: activeCriteria ?? this.activeCriteria,
      matchingFlights: matchingFlights ?? this.matchingFlights,
      smartBadges: smartBadges ?? this.smartBadges,
      lastExpectedParameter: lastExpectedParameter ?? this.lastExpectedParameter,
      partialRecognizedText: partialRecognizedText ?? this.partialRecognizedText,
      isTtsMuted: isTtsMuted ?? this.isTtsMuted,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedFlightForBooking: clearSelectedFlight ? null : (selectedFlightForBooking ?? this.selectedFlightForBooking),
      passengerDetails: passengerDetails ?? this.passengerDetails,
      bookingStep: bookingStep ?? this.bookingStep,
      latestConfirmedBooking: latestConfirmedBooking ?? this.latestConfirmedBooking,
    );
  }

  @override
  List<Object?> get props => [
        voiceStatus,
        messages,
        activeCriteria,
        matchingFlights,
        smartBadges,
        lastExpectedParameter,
        partialRecognizedText,
        isTtsMuted,
        geminiApiKey,
        errorMessage,
        selectedFlightForBooking,
        passengerDetails,
        bookingStep,
        latestConfirmedBooking,
      ];
}
