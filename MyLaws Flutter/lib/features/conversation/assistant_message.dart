import 'package:flutter/material.dart';
import '../../app/providers.dart';
import '../../core/widgets/superseded_banner.dart';
import '../../core/widgets/typewriter_text.dart';
import '../answer/answer_card.dart';

class AssistantMessage extends StatelessWidget {
  final ChatMessage message;
  final bool isBangla;
  final ValueChanged<String>? onChecklistToggled;
  final VoidCallback? onPrepareDraft;

  const AssistantMessage({
    super.key,
    required this.message,
    required this.isBangla,
    this.onChecklistToggled,
    this.onPrepareDraft,
  });

  @override
  Widget build(BuildContext context) {
    final response = message.response;

    Widget content;
    if (response != null) {
      content = AnswerCard(
        response: response,
        isBangla: isBangla,
        onChecklistToggled: onChecklistToggled,
        onPrepareDraft: onPrepareDraft,
        animate: message.shouldAnimate,
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TypewriterText(
          text: message.text,
          animate: message.shouldAnimate,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
      );
    }

    if (message.isSuperseded) {
      content = SupersededBanner(
        isBangla: isBangla,
        child: content,
      );
    }

    return content;
  }
}
