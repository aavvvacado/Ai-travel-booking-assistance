import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RecordingOverlayBar extends StatefulWidget {
  final String? partialText;
  final VoidCallback onStopAndSend;
  final VoidCallback onCancel;

  const RecordingOverlayBar({
    super.key,
    required this.partialText,
    required this.onStopAndSend,
    required this.onCancel,
  });

  @override
  State<RecordingOverlayBar> createState() => _RecordingOverlayBarState();
}

class _RecordingOverlayBarState extends State<RecordingOverlayBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = (widget.partialText != null && widget.partialText!.isNotEmpty)
        ? widget.partialText!
        : 'Listening... speak your travel request';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.iosRed.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.iosRed.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Live Recording Indicator + Cancel Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.iosRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'RECORDING AUDIO',
                    style: TextStyle(
                      color: AppColors.iosRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: widget.onCancel,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Real-time Recognized Speech Preview Bubble
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              displayText,
              style: TextStyle(
                color: (widget.partialText != null && widget.partialText!.isNotEmpty)
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
                fontSize: 14,
                fontStyle: (widget.partialText == null || widget.partialText!.isEmpty)
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Audio Sound Wave Bars + Stop & Send CTA Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sound wave animation bars
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Row(
                    children: List.generate(5, (index) {
                      final heights = [12.0, 24.0, 16.0, 28.0, 14.0];
                      final height = heights[index] * (0.6 + (_animationController.value * 0.4));
                      return Container(
                        width: 4,
                        height: height,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: index % 2 == 0 ? AppColors.primary : AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  );
                },
              ),

              // Stop & Send Button
              ElevatedButton.icon(
                onPressed: widget.onStopAndSend,
                icon: const Icon(Icons.stop_rounded, color: Colors.white, size: 18),
                label: const Text('Stop & Send', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.iosRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
