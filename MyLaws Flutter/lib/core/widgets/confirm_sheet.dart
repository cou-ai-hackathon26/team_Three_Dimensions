import 'package:flutter/material.dart';
import '../theme/theme_extension.dart';

class ConfirmSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const ConfirmSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'বাতিল / Cancel',
    this.isDestructive = false,
    required this.onConfirm,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    String? message,
    String? description,
    required String confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
  }) async {
    final effectiveMessage = message ?? description ?? '';
    final effectiveCancel = cancelLabel ?? 'বাতিল / Cancel';

    final res = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ConfirmSheet(
        title: title,
        message: effectiveMessage,
        confirmLabel: confirmLabel,
        cancelLabel: effectiveCancel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.pop(ctx, true),
      ),
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDestructive ? ext.critical : ext.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ext.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: isDestructive
                        ? ElevatedButton.styleFrom(
                            backgroundColor: ext.critical,
                            foregroundColor: ext.onPrimary,
                          )
                        : null,
                    onPressed: onConfirm,
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
