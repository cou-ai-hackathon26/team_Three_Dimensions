import 'dart:async';
import 'package:flutter/material.dart';

/// Interactive typewriter widget that smoothly reveals text
/// character-by-character or chunk-by-chunk to emulate live AI generation.
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool animate;
  final Duration charDuration;
  final VoidCallback? onComplete;
  final Color? cursorColor;
  final TextAlign? textAlign;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.animate = false,
    this.charDuration = const Duration(milliseconds: 20),
    this.onComplete,
    this.cursorColor,
    this.textAlign,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  int _charCount = 0;
  Timer? _timer;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    if (widget.animate && widget.text.isNotEmpty) {
      _isComplete = false;
      _charCount = 0;
      _start();
    } else {
      _charCount = widget.text.length;
      _isComplete = true;
    }
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      if (widget.animate && widget.text.isNotEmpty) {
        _isComplete = false;
        _charCount = 0;
        _start();
      } else {
        _charCount = widget.text.length;
        _isComplete = true;
      }
    }
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.charDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _charCount += 2;
        if (_charCount >= widget.text.length) {
          _charCount = widget.text.length;
          _isComplete = true;
          timer.cancel();
          widget.onComplete?.call();
        }
      });
    });
  }

  void _skip() {
    if (_isComplete) return;
    _timer?.cancel();
    setState(() {
      _charCount = widget.text.length;
      _isComplete = true;
    });
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _isComplete
        ? widget.text
        : widget.text.substring(0, _charCount.clamp(0, widget.text.length));

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final caretColor = widget.cursorColor ??
        (isDark ? const Color(0xFFD4A853) : const Color(0xFF8C6735));

    return GestureDetector(
      onTap: _skip,
      behavior: HitTestBehavior.opaque,
      child: SelectableText.rich(
        TextSpan(
          text: visible,
          style: widget.style,
          children: [
            if (!_isComplete)
              TextSpan(
                text: ' ▌',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: caretColor,
                ),
              ),
          ],
        ),
        textAlign: widget.textAlign ?? TextAlign.start,
      ),
    );
  }
}
