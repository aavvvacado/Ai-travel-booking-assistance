import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/voice_chat_state.dart';

class ChatGptInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoiceStateStatus voiceStatus;
  final String? partialText;
  final Function(String text) onSendText;
  final VoidCallback onStartListening;
  final VoidCallback onStopAndSend;
  final VoidCallback onCancelListening;

  const ChatGptInputBar({
    super.key,
    required this.controller,
    required this.voiceStatus,
    required this.partialText,
    required this.onSendText,
    required this.onStartListening,
    required this.onStopAndSend,
    required this.onCancelListening,
  });

  @override
  State<ChatGptInputBar> createState() => _ChatGptInputBarState();
}

class _ChatGptInputBarState extends State<ChatGptInputBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant ChatGptInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.voiceStatus == VoiceStateStatus.listening &&
        widget.partialText != null &&
        widget.partialText != oldWidget.partialText) {
      widget.controller.text = widget.partialText!;
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _pulseController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isListening = widget.voiceStatus == VoiceStateStatus.listening;
    final isProcessing = widget.voiceStatus == VoiceStateStatus.processing;
    final hasText = widget.controller.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isListening
                  ? AppColors.error
                  : (hasText ? AppColors.accent : AppColors.border),
              width: isListening ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              if (isListening)
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Row(
                          children: List.generate(4, (index) {
                            final heights = [10.0, 18.0, 12.0, 22.0];
                            final height = heights[index] * (0.6 + (_pulseController.value * 0.4));
                            return Container(
                              width: 3,
                              height: height,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                )
              else if (isProcessing)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0, left: 4.0),
                  child: Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
                ),

              Expanded(
                child: TextField(
                  controller: widget.controller,
                  minLines: 1,
                  maxLines: 5,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      widget.onSendText(val.trim());
                    }
                  },
                  decoration: InputDecoration(
                    hintText: isListening
                        ? 'Listening...'
                        : (isProcessing ? 'Thinking...' : 'Ask AI travel assistant or tap mic...'),
                    hintStyle: TextStyle(
                      color: isListening ? AppColors.error : AppColors.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              if (isListening)
                Row(
                  children: [
                    InkWell(
                      onTap: widget.onCancelListening,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: widget.onStopAndSend,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                )
              else
                InkWell(
                  onTap: hasText
                      ? () => widget.onSendText(widget.controller.text.trim())
                      : widget.onStartListening,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasText ? AppColors.accent : AppColors.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasText ? Icons.arrow_upward_rounded : Icons.graphic_eq_rounded,
                      size: 16,
                      color: hasText ? Colors.white : AppColors.accent,
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
