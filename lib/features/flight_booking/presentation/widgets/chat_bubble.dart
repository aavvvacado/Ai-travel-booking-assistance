import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/flight.dart';
import 'flight_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Map<String, String> smartBadges;
  final String? selectedFlightId;
  final Function(Flight flight)? onSelectFlight;

  const ChatBubble({
    super.key,
    required this.message,
    this.smartBadges = const {},
    this.selectedFlightId,
    this.onSelectFlight,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isUser)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.userBubble,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

          // Render Flight Cards cleanly below assistant text
          if (!isUser && message.hasFlights) ...[
            const SizedBox(height: 10),
            Column(
              children: message.recommendedFlights!.map((flight) {
                final badge = smartBadges[flight.id];
                final isSelected = (selectedFlightId == flight.id);

                return FlightCard(
                  flight: flight,
                  smartBadge: badge,
                  isSelected: isSelected,
                  onSelect: () {
                    if (onSelectFlight != null) {
                      onSelectFlight!(flight);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
