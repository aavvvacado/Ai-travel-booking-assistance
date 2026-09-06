import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/voice_chat_state.dart';

class MinimalMicButton extends StatefulWidget {
  final VoiceStateStatus status;
  final VoidCallback onTap;

  const MinimalMicButton({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  State<MinimalMicButton> createState() => _MinimalMicButtonState();
}

class _MinimalMicButtonState extends State<MinimalMicButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getMicColor() {
    switch (widget.status) {
      case VoiceStateStatus.listening:
        return AppColors.iosRed;
      case VoiceStateStatus.processing:
        return AppColors.warning;
      case VoiceStateStatus.speaking:
        return AppColors.accent;
      case VoiceStateStatus.error:
        return AppColors.error;
      case VoiceStateStatus.idle:
        return AppColors.primary;
    }
  }

  IconData _getMicIcon() {
    switch (widget.status) {
      case VoiceStateStatus.listening:
        return Icons.stop_rounded;
      case VoiceStateStatus.processing:
        return Icons.auto_awesome;
      case VoiceStateStatus.speaking:
        return Icons.volume_up;
      case VoiceStateStatus.idle:
        return Icons.mic;
      case VoiceStateStatus.error:
        return Icons.mic_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAnimated = widget.status == VoiceStateStatus.listening ||
        widget.status == VoiceStateStatus.processing ||
        widget.status == VoiceStateStatus.speaking;

    final micColor = _getMicColor();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = isAnimated ? _scaleAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: micColor,
              boxShadow: [
                BoxShadow(
                  color: micColor.withValues(alpha: isAnimated ? 0.4 : 0.2),
                  blurRadius: isAnimated ? 12 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    _getMicIcon(),
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
