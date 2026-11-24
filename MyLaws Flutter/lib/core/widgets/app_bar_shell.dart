import 'package:flutter/material.dart';
import '../theme/theme_extension.dart';

class AppBarShell extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBack;
  final Color? backgroundColor;

  const AppBarShell({
    super.key,
    this.title = '',
    this.showBack = false,
    this.leading,
    this.actions,
    this.bottom,
    this.onBack,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    Widget? resolvedLeading = leading;
    if (resolvedLeading == null && showBack) {
      resolvedLeading = IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      );
    }

    Widget? titleWidget;
    if (title.isNotEmpty) {
      titleWidget = Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: ext.onSurface,
        ),
      );
    }

    return AppBar(
      leading: resolvedLeading,
      automaticallyImplyLeading: showBack && resolvedLeading == null,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor ?? ext.surface,
      surfaceTintColor: Colors.transparent,
      titleSpacing: showBack ? 0 : 16,
      title: titleWidget,
      actions: actions,
      bottom: bottom,
    );
  }
}
