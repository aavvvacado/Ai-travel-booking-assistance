import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/flight.dart';
import '../../domain/entities/search_criteria.dart';
import 'flight_card.dart';

class FlightListSheet extends StatefulWidget {
  final List<Flight> flights;
  final SearchCriteria criteria;
  final Function(Flight flight) onSelectFlight;

  const FlightListSheet({
    super.key,
    required this.flights,
    required this.criteria,
    required this.onSelectFlight,
  });

  @override
  State<FlightListSheet> createState() => _FlightListSheetState();
}

class _FlightListSheetState extends State<FlightListSheet> {
  late SortPreference _sortPreference;

  @override
  void initState() {
    super.initState();
    _sortPreference = widget.criteria.sortPreference;
  }

  List<Flight> _getSortedFlights() {
    final list = List<Flight>.from(widget.flights);
    if (_sortPreference == SortPreference.cheapest) {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortPreference == SortPreference.fastest) {
      list.sort((a, b) => a.duration.compareTo(b.duration));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final sortedFlights = _getSortedFlights();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Flights (${sortedFlights.length})',
                style: const TextStyle(
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

          // Sort Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Cheapest First'),
                  selected: _sortPreference == SortPreference.cheapest,
                  onSelected: (selected) {
                    if (selected) setState(() => _sortPreference = SortPreference.cheapest);
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Fastest Duration'),
                  selected: _sortPreference == SortPreference.fastest,
                  onSelected: (selected) {
                    if (selected) setState(() => _sortPreference = SortPreference.fastest);
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Flight Cards List
          Expanded(
            child: sortedFlights.isEmpty
                ? const Center(
                    child: Text(
                      'No matching flights found.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: sortedFlights.length,
                    itemBuilder: (context, index) {
                      final flight = sortedFlights[index];
                      return FlightCard(
                        flight: flight,
                        onSelect: () {
                          Navigator.pop(context);
                          widget.onSelectFlight(flight);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
