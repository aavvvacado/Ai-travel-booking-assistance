import 'package:equatable/equatable.dart';
import '../../domain/entities/search_criteria.dart';
import '../../domain/entities/flight.dart';
import '../../domain/entities/passenger_details.dart';
import 'voice_chat_state.dart';

abstract class VoiceChatEvent extends Equatable {
  const VoiceChatEvent();

  @override
  List<Object?> get props => [];
}

class InitVoiceChatEvent extends VoiceChatEvent {}

class StartListeningEvent extends VoiceChatEvent {}

class StopListeningEvent extends VoiceChatEvent {}

class CancelListeningEvent extends VoiceChatEvent {}

class SpeechRecognizedEvent extends VoiceChatEvent {
  final String recognizedText;
  const SpeechRecognizedEvent(this.recognizedText);

  @override
  List<Object?> get props => [recognizedText];
}

class SendTextMessageEvent extends VoiceChatEvent {
  final String text;
  const SendTextMessageEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class UpdateCriteriaEvent extends VoiceChatEvent {
  final SearchCriteria criteria;
  const UpdateCriteriaEvent(this.criteria);

  @override
  List<Object?> get props => [criteria];
}

class ClearCriteriaEvent extends VoiceChatEvent {}

class ToggleMuteTtsEvent extends VoiceChatEvent {}

class SetGeminiApiKeyEvent extends VoiceChatEvent {
  final String apiKey;
  const SetGeminiApiKeyEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class SelectFlightForBookingEvent extends VoiceChatEvent {
  final Flight flight;
  const SelectFlightForBookingEvent(this.flight);

  @override
  List<Object?> get props => [flight];
}

class SetBookingStepEvent extends VoiceChatEvent {
  final BookingStep step;
  const SetBookingStepEvent(this.step);

  @override
  List<Object?> get props => [step];
}

class UpdatePassengerDetailsEvent extends VoiceChatEvent {
  final PassengerDetails details;
  const UpdatePassengerDetailsEvent(this.details);

  @override
  List<Object?> get props => [details];
}

class ConfirmSelectedBookingEvent extends VoiceChatEvent {}

class CancelCurrentBookingFlowEvent extends VoiceChatEvent {}
