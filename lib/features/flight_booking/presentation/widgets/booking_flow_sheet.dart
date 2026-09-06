import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/flight.dart';
import '../../domain/entities/passenger_details.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/voice_chat_bloc.dart';
import '../bloc/voice_chat_event.dart';
import '../bloc/voice_chat_state.dart';

class BookingFlowSheet extends StatefulWidget {
  final Flight flight;
  final VoidCallback onClose;

  const BookingFlowSheet({
    super.key,
    required this.flight,
    required this.onClose,
  });

  @override
  State<BookingFlowSheet> createState() => _BookingFlowSheetState();
}

class _BookingFlowSheetState extends State<BookingFlowSheet> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final state = context.read<VoiceChatBloc>().state;
    final details = state.passengerDetails;

    _nameController = TextEditingController(text: details?.fullName ?? 'Vishal Pratap Singh');
    _emailController = TextEditingController(text: details?.email ?? 'vishal@example.com');
    _phoneController = TextEditingController(text: details?.phone ?? '+91 98765 43210');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _savePassengerAndNext() {
    final details = PassengerDetails(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    context.read<VoiceChatBloc>().add(UpdatePassengerDetailsEvent(details));
    context.read<VoiceChatBloc>().add(const SetBookingStepEvent(BookingStep.reviewBooking));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceChatBloc, VoiceChatState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStepContent(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepContent(BuildContext context, VoiceChatState state) {
    switch (state.bookingStep) {
      case BookingStep.flightDetails:
        return _buildFlightDetailsStep(context, state);
      case BookingStep.passengerInput:
        return _buildPassengerFormStep(context);
      case BookingStep.reviewBooking:
        return _buildReviewBookingStep(context, state);
      case BookingStep.processing:
        return _buildProcessingStep();
      case BookingStep.confirmed:
        return _buildConfirmationStep(context, state.latestConfirmedBooking);
      default:
        return _buildFlightDetailsStep(context, state);
    }
  }

  // Step 1: Flight Details & Timeline
  Widget _buildFlightDetailsStep(BuildContext context, VoiceChatState state) {
    return Column(
      key: const ValueKey('step_details'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Flight Details',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
              onPressed: widget.onClose,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Route & Timeline Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.flight.airline,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const Spacer(),
                  Text(
                    widget.flight.flightNumber,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Vertical Timeline
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Times & Codes
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.flight.departureTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(widget.flight.originCode, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 24),
                      Text(widget.flight.arrivalTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(widget.flight.destinationCode, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Line indicator
                  Column(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
                      Container(width: 2, height: 48, color: AppColors.border),
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Names & Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.flight.origin, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.flight.duration} · ${widget.flight.isDirect ? "Non-stop" : "1 Stop"}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Text(widget.flight.destination, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Fare', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text('₹${widget.flight.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            context.read<VoiceChatBloc>().add(const SetBookingStepEvent(BookingStep.passengerInput));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Continue to passenger details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  // Step 2: Passenger Details Form
  Widget _buildPassengerFormStep(BuildContext context) {
    return Column(
      key: const ValueKey('step_passenger'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () {
                context.read<VoiceChatBloc>().add(const SetBookingStepEvent(BookingStep.flightDetails));
              },
            ),
            const Text(
              'Passenger Details',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Full Name', hintText: 'Enter passenger full name'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email Address', hintText: 'name@example.com'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: 'Phone Number', hintText: '+91 98765 43210'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _savePassengerAndNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Review trip details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  // Step 3: Review Booking Screen
  Widget _buildReviewBookingStep(BuildContext context, VoiceChatState state) {
    final passengerName = _nameController.text.trim();

    return Column(
      key: const ValueKey('step_review'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () {
                context.read<VoiceChatBloc>().add(const SetBookingStepEvent(BookingStep.passengerInput));
              },
            ),
            const Text(
              'Review your trip',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.flight.origin} → ${widget.flight.destination}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.flight.departureTime} → ${widget.flight.arrivalTime} · ${widget.flight.isDirect ? "Non-stop" : "1 Stop"}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.flight.airline} ${widget.flight.flightNumber}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const Divider(height: 20, color: AppColors.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Passenger', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  Text(passengerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Price', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  Text('₹${widget.flight.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            final passenger = state.passengerDetails ??
                PassengerDetails(
                  fullName: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                  phone: _phoneController.text.trim(),
                );

            context.read<BookingBloc>().add(
                  CreateBookingEvent(
                    flight: widget.flight,
                    passengerName: passenger.fullName,
                    passengerEmail: passenger.email,
                    passportOrId: passenger.phone,
                    seatNumber: '12A',
                  ),
                );

            context.read<VoiceChatBloc>().add(ConfirmSelectedBookingEvent());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Confirm booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  // Step 4: Processing State
  Widget _buildProcessingStep() {
    return const Padding(
      key: ValueKey('step_processing'),
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 3),
          ),
          SizedBox(height: 16),
          Text(
            'Confirming your booking...',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Step 5: Booking Confirmation Card (Requirement 21)
  Widget _buildConfirmationStep(BuildContext context, Booking? booking) {
    final ref = booking?.bookingId ?? 'TRV-8F42KQ';

    return Column(
      key: const ValueKey('step_confirmed'),
      children: [
        const SizedBox(height: 10),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 12),
        const Text(
          "You're booked",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text(
                '${widget.flight.origin} → ${widget.flight.destination}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.flight.departureTime} → ${widget.flight.arrivalTime}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.flight.airline} ${widget.flight.flightNumber}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const Divider(height: 20, color: AppColors.border),
              const Text('Booking Reference', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              const SizedBox(height: 2),
              Text(
                ref,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.accent, letterSpacing: 1),
              ),
              const SizedBox(height: 10),
              Text('₹${widget.flight.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            context.read<VoiceChatBloc>().add(CancelCurrentBookingFlowEvent());
            widget.onClose();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }
}
