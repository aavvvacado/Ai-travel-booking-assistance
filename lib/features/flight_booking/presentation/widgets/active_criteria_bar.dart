import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/search_criteria.dart';

class ActiveCriteriaBar extends StatelessWidget {
  final SearchCriteria criteria;
  final VoidCallback onClear;

  const ActiveCriteriaBar({
    super.key,
    required this.criteria,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (criteria.origin != null) {
      chips.add(_buildChip(context, Icons.flight_takeoff, 'From: ${criteria.origin}'));
    }
    if (criteria.destination != null) {
      chips.add(_buildChip(context, Icons.flight_land, 'To: ${criteria.destination}'));
    }
    if (criteria.dateText != null) {
      chips.add(_buildChip(context, Icons.calendar_today, criteria.dateText!));
    }
    if (criteria.directOnly == true) {
      chips.add(_buildChip(context, Icons.flight_takeoff, 'Direct Flight'));
    }
    if (criteria.maxPrice != null) {
      chips.add(_buildChip(context, Icons.attach_money, 'Max \$${criteria.maxPrice!.toInt()}'));
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: chips,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.close,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
