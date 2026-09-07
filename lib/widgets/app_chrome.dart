import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../settings.dart';

PreferredSizeWidget buildAppBar(
  BuildContext context,
  String title, {
  bool showBack = true,
}) {
  final settings = SettingsScope.of(context);
  final isDark = settings.themeMode == ThemeMode.dark;

  return AppBar(
    title: Text(title),
    leading: showBack
        ? IconButton(
            tooltip: 'Назад',
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          )
        : null,
    actions: [
      IconButton(
        tooltip: isDark ? 'Светлая тема' : 'Тёмная тема',
        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
        onPressed: settings.toggleTheme,
      ),
    ],
  );
}

class NarrowBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const NarrowBody({
    super.key,
    required this.child,
    this.maxWidth = 420,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth < 400 ? 16 : 24,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
