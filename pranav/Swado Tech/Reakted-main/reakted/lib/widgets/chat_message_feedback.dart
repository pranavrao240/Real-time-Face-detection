import 'package:flutter/material.dart';
import 'package:reakted/widgets/feedback_widget.dart';
import 'package:reakted/providers/home_provider.dart';

class ChatMessageFeedback extends StatelessWidget {
  final ChatMessage message;
  final void Function(bool isPositive)? onFeedback;

  const ChatMessageFeedback({Key? key, required this.message, this.onFeedback})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmartFeedbackWidget(
      responseId: message.id,
      onFeedback: onFeedback,
      context: message.userMessage,
    );
  }
}
