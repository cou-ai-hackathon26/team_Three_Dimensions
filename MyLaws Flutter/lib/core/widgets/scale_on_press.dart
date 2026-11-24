import 'package:flutter/material.dart';

/// Provides a subtle tactile spring micro-scale effect on touch down (default: 0.96).
/// Uses Pointer events via [Listener] so it does not intercept or delay gesture recognition.
class ScaleOnPress extends StatefulWidget {
  final Widget child;
  final double pressedScale;
  final Duration duration;
  final Curve curve;

  const ScaleOnPress({
    super.key,
    required this.child,
    this.pressedScale = 0.96,
    this.duration = const Duration(milliseconds: 120),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<ScaleOnPress> createState() => _ScaleOnPressState();
}

class _ScaleOnPressState extends State<ScaleOnPress> {
  bool _isPressed = false;

  void _handlePointer(bool pressed) {
    if (_isPressed != pressed && mounted) {
      setState(() {
        _isPressed = pressed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _handlePointer(true),
      onPointerUp: (_) => _handlePointer(false),
      onPointerCancel: (_) => _handlePointer(false),
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}
