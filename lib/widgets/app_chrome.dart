import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../settings.dart';
import '../state/auth_notifier.dart';

PreferredSizeWidget buildAppBar(
  BuildContext context,
  String title, {
  bool showBack = true,
}) {
  final settings = SettingsScope.of(context);
  final isDark = settings.themeMode == ThemeMode.dark;
  final auth = context.watch<AuthNotifier>();

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
      if (auth.user != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                '${auth.user!.displayName} · ${auth.uiRole.title}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ),
      if (auth.isAuthenticated)
        IconButton(
          tooltip: 'Выйти',
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await auth.logout();
            if (context.mounted) context.go('/login');
          },
        ),
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

  const NarrowBody({super.key, required this.child, this.maxWidth = 420});

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
