import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/flight.dart';

class BookingDialog extends StatefulWidget {
  final Flight flight;
  final Function({
    required String name,
    required String email,
    required String passport,
    required String seat,
  }) onConfirm;

  const BookingDialog({
    super.key,
    required this.flight,
    required this.onConfirm,
  });

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Ashish Kumar');
  final _emailController = TextEditingController(text: 'ashish@example.com');
  final _passportController = TextEditingController(text: 'A98765432');
  String _selectedSeat = '12A (Window)';

  final List<String> _seatOptions = [
    '12A (Window)',
    '12B (Middle)',
    '12C (Aisle)',
    '14A (Window)',
    '14C (Aisle)',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Passenger Booking Details',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Selected Flight Summary Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.flight.airline} (${widget.flight.flightNumber})',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.flight.origin} → ${widget.flight.destination} (${widget.flight.departureTime})',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      '\$${widget.flight.price.toInt()}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Passenger Full Name
              const Text('Full Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                decoration: const InputDecoration(hintText: 'Enter passenger full name'),
              ),

              const SizedBox(height: 12),

              // Email Address
              const Text('Email Address', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: AppColors.textPrimary),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                decoration: const InputDecoration(hintText: 'Enter email for ticket delivery'),
              ),

              const SizedBox(height: 12),

              // Passport / Govt ID
              const Text('Passport / Govt ID Number', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passportController,
                style: const TextStyle(color: AppColors.textPrimary),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                decoration: const InputDecoration(hintText: 'Enter passport or ID number'),
              ),

              const SizedBox(height: 12),

              // Seat Preference
              const Text('Seat Preference', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedSeat,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(),
                items: _seatOptions.map((seat) {
                  return DropdownMenuItem(value: seat, child: Text(seat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSeat = val);
                },
              ),

              const SizedBox(height: 20),

              // Confirm CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      widget.onConfirm(
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        passport: _passportController.text.trim(),
                        seat: _selectedSeat,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Confirm & Generate Digital Ticket',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
