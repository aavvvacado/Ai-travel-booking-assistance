import 'package:equatable/equatable.dart';
import 'flight.dart';
import 'search_criteria.dart';

enum MessageSender { user, ai, system }

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final List<Flight>? recommendedFlights;
  final SearchCriteria? activeCriteria;
  final String? reasoning;
  final bool isBookingPrompt;
  final Flight? selectedFlightForBooking;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.recommendedFlights,
    this.activeCriteria,
    this.reasoning,
    this.isBookingPrompt = false,
    this.selectedFlightForBooking,
  });

  bool get hasFlights => recommendedFlights != null && recommendedFlights!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        text,
        sender,
        timestamp,
        recommendedFlights,
        activeCriteria,
        reasoning,
        isBookingPrompt,
        selectedFlightForBooking,
      ];
}
