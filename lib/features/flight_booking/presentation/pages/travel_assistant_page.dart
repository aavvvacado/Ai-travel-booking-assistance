import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/flight.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../bloc/voice_chat_bloc.dart';
import '../bloc/voice_chat_event.dart';
import '../bloc/voice_chat_state.dart';
import '../widgets/active_criteria_bar.dart';
import '../widgets/booking_flow_sheet.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_gpt_input_bar.dart';
import '../widgets/flight_results_header.dart';
import 'ticket_view_page.dart';

class TravelAssistantPage extends StatefulWidget {
  const TravelAssistantPage({super.key});

  @override
  State<TravelAssistantPage> createState() => _TravelAssistantPageState();
}

class _TravelAssistantPageState extends State<TravelAssistantPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<VoiceChatBloc>().add(InitVoiceChatEvent());
    context.read<BookingBloc>().add(LoadUserBookingsEvent());
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showBookingFlowSheet(BuildContext context, Flight flight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BookingFlowSheet(
        flight: flight,
        onClose: () {
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    final controller = TextEditingController(
      text: context.read<VoiceChatBloc>().state.geminiApiKey ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Configure Gemini AI Key',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Google Gemini API Key for online LLM reasoning. Leave blank for zero-config local rule engine.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'AIzaSy...'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<VoiceChatBloc>().add(
                SetGeminiApiKeyEvent(controller.text.trim()),
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text(
              'Save Key',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.flight_takeoff,
                color: AppColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Travel Assistant',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Natural search & booking',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          BlocBuilder<VoiceChatBloc, VoiceChatState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.isTtsMuted ? Icons.volume_off : Icons.volume_up,
                  color: state.isTtsMuted
                      ? AppColors.textMuted
                      : AppColors.accent,
                ),
                tooltip: state.isTtsMuted ? 'Unmute AI Voice' : 'Mute AI Voice',
                onPressed: () =>
                    context.read<VoiceChatBloc>().add(ToggleMuteTtsEvent()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.vpn_key_outlined,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Gemini API Key',
            onPressed: () => _showApiKeyDialog(context),
          ),
          BlocBuilder<BookingBloc, BookingState>(
            builder: (context, state) {
              final activeCount = state.bookings.length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.confirmation_number_outlined,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {
                      if (state.bookings.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) =>
                                TicketViewPage(booking: state.bookings.first),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No active bookings yet.'),
                          ),
                        );
                      }
                    },
                  ),
                  if (activeCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$activeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MultiBlocListener(
          listeners: [
            BlocListener<BookingBloc, BookingState>(
              listener: (context, state) {
                if (state.status == BookingStateStatus.success &&
                    state.latestConfirmedBooking != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Booking Confirmed! ID: ${state.latestConfirmedBooking!.bookingId}',
                      ),
                      backgroundColor: AppColors.success,
                      action: SnackBarAction(
                        label: 'View Ticket',
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => TicketViewPage(
                                booking: state.latestConfirmedBooking!,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
            BlocListener<VoiceChatBloc, VoiceChatState>(
              listenWhen: (previous, current) =>
                  previous.messages.length != current.messages.length ||
                  previous.voiceStatus != current.voiceStatus ||
                  previous.bookingStep != current.bookingStep ||
                  previous.latestConfirmedBooking !=
                      current.latestConfirmedBooking,
              listener: (context, state) {
                _scrollToBottom();

                if (state.latestConfirmedBooking != null &&
                    state.bookingStep == BookingStep.confirmed) {
                  final b = state.latestConfirmedBooking!;
                  context.read<BookingBloc>().add(
                    CreateBookingEvent(
                      flight: b.flight,
                      passengerName: b.passengerName,
                      passengerEmail: b.passengerEmail,
                      passportOrId: b.passportOrId,
                      seatNumber: b.seatNumber,
                    ),
                  );
                }

                if (state.bookingStep != BookingStep.none) {
                  TtsService().stop();
                }

                if (state.voiceStatus == VoiceStateStatus.speaking &&
                    state.bookingStep == BookingStep.none &&
                    state.messages.isNotEmpty &&
                    state.messages.last.sender == MessageSender.ai) {
                  TtsService().speak(state.messages.last.text);
                }

                if (state.isListening) {
                  TtsService().stop();
                }

                if (state.selectedFlightForBooking != null &&
                    state.bookingStep != BookingStep.none) {
                  _showBookingFlowSheet(
                    context,
                    state.selectedFlightForBooking!,
                  );
                }
              },
            ),
          ],
          child: Column(
            children: [
              // Active Criteria Toolbar Chips
              BlocBuilder<VoiceChatBloc, VoiceChatState>(
                builder: (context, state) {
                  return ActiveCriteriaBar(
                    criteria: state.activeCriteria,
                    onClear: () {
                      context.read<VoiceChatBloc>().add(ClearCriteriaEvent());
                    },
                  );
                },
              ),

              // Transcript Chat Stream & Rich Flight Results
              Expanded(
                child: BlocBuilder<VoiceChatBloc, VoiceChatState>(
                  builder: (context, state) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 12, bottom: 20),
                      itemCount:
                          state.messages.length +
                          (state.matchingFlights.isNotEmpty ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (state.matchingFlights.isNotEmpty &&
                            index == state.messages.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: FlightResultsHeader(
                              criteria: state.activeCriteria,
                              count: state.matchingFlights.length,
                            ),
                          );
                        }

                        final msg = state.messages[index];
                        return ChatBubble(
                          message: msg,
                          smartBadges: state.smartBadges,
                          selectedFlightId: state.selectedFlightForBooking?.id,
                          onSelectFlight: (flight) {
                            context.read<VoiceChatBloc>().add(
                              SelectFlightForBookingEvent(flight),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // Selected Flight Bottom Bar CTA (if flight selected)
              BlocBuilder<VoiceChatBloc, VoiceChatState>(
                builder: (context, state) {
                  if (state.selectedFlightForBooking == null)
                    return const SizedBox.shrink();

                  final flight = state.selectedFlightForBooking!;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${flight.airline} ${flight.flightNumber}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '₹${flight.price.toInt()} · ${flight.departureTime} → ${flight.arrivalTime}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showBookingFlowSheet(context, flight);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Continue to booking',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Quick Suggestions
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    _buildQuickPill(context, 'Delhi to Dubai next weekend'),
                    const SizedBox(width: 8),
                    _buildQuickPill(
                      context,
                      'Cheapest direct flight under 20k',
                    ),
                    const SizedBox(width: 8),
                    _buildQuickPill(context, 'Mumbai to Dubai tomorrow'),
                  ],
                ),
              ),

              // Input Bar
              BlocBuilder<VoiceChatBloc, VoiceChatState>(
                builder: (context, state) {
                  return ChatGptInputBar(
                    controller: _textController,
                    voiceStatus: state.voiceStatus,
                    partialText: state.partialRecognizedText,
                    onSendText: (text) {
                      context.read<VoiceChatBloc>().add(
                        SendTextMessageEvent(text),
                      );
                      _textController.clear();
                      _scrollToBottom();
                    },
                    onStartListening: () {
                      context.read<VoiceChatBloc>().add(StartListeningEvent());
                    },
                    onStopAndSend: () {
                      context.read<VoiceChatBloc>().add(StopListeningEvent());
                      _textController.clear();
                      _scrollToBottom();
                    },
                    onCancelListening: () {
                      context.read<VoiceChatBloc>().add(CancelListeningEvent());
                      _textController.clear();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPill(BuildContext context, String text) {
    return InkWell(
      onTap: () {
        context.read<VoiceChatBloc>().add(SendTextMessageEvent(text));
        _scrollToBottom();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
