import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/providers.dart';
import '../../core/theme/app_colors.dart';
import 'assistant_message.dart';
import 'legal_reasoning_indicator.dart';
import 'user_bubble.dart';

class ThreadView extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool isWorking;
  final bool isBangla;
  final VoidCallback onStop;
  final ValueChanged<String>? onChecklistToggled;
  final VoidCallback? onPrepareDraft;

  const ThreadView({
    super.key,
    required this.messages,
    required this.isWorking,
    required this.isBangla,
    required this.onStop,
    this.onChecklistToggled,
    this.onPrepareDraft,
  });

  @override
  State<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void didUpdateWidget(ThreadView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length ||
        (widget.isWorking && !oldWidget.isWorking)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final isFarFromBottom = (maxScroll - currentScroll) > 180;
    if (isFarFromBottom != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = isFarFromBottom;
      });
    }
  }

  void _scrollToBottom() {
    HapticFeedback.lightImpact();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bronzeColor = isDark ? AppColors.darkGold : AppColors.warmBronze;

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          itemCount: widget.messages.length + (widget.isWorking ? 1 : 0),
          itemBuilder: (ctx, index) {
            if (index == widget.messages.length && widget.isWorking) {
              return ThreadMessageEntrance(
                key: const ValueKey('reasoning_indicator'),
                child: LegalReasoningIndicator(
                  isBangla: widget.isBangla,
                  onStop: widget.onStop,
                ),
              );
            }

            final message = widget.messages[index];
            final childWidget = message.role == 'user'
                ? UserBubble(text: message.text)
                : AssistantMessage(
                    message: message,
                    isBangla: widget.isBangla,
                    onChecklistToggled: widget.onChecklistToggled,
                    onPrepareDraft: widget.onPrepareDraft,
                  );

            return ThreadMessageEntrance(
              key: ValueKey(message.id),
              child: childWidget,
            );
          },
        ),
        if (_showScrollToBottom)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.small(
              backgroundColor: isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurfaceElevated,
              foregroundColor:
                  isDark ? AppColors.darkGold : AppColors.antiqueGold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: bronzeColor.withValues(alpha: 0.55),
                  width: 1.5,
                ),
              ),
              elevation: 3,
              tooltip: widget.isBangla ? 'সর্বশেষ বার্তা' : 'Latest reply',
              onPressed: _scrollToBottom,
              child: const Icon(Icons.arrow_downward, size: 18),
            ),
          ),
      ],
    );
  }
}

/// Wraps incoming messages with a smooth entrance animation:
/// glides 16px upwards into place with a subtle spring curve (Curves.easeOutCubic, 350ms)
/// and fades in opacity from 0.0 to 1.0.
class ThreadMessageEntrance extends StatefulWidget {
  final Widget child;

  const ThreadMessageEntrance({
    super.key,
    required this.child,
  });

  @override
  State<ThreadMessageEntrance> createState() => _ThreadMessageEntranceState();
}

class _ThreadMessageEntranceState extends State<ThreadMessageEntrance>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final val = _animation.value;
        return Opacity(
          opacity: val.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1.0 - val) * 16.0),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
