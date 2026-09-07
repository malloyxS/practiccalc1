import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/breakpoints.dart';
import '../data/catalog_cache.dart';
import '../models/role.dart';
import '../state/auth_notifier.dart';
import '../widgets/app_chrome.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CatalogCache>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final columns = homeColumns(context);
    final buttons = <Widget>[
      FilledButton.icon(
        onPressed: () => context.go('/books'),
        icon: const Icon(Icons.menu_book),
        label: const Text('Каталог книг'),
      ),
      if (auth.can(Operation.viewOwnLoans))
        FilledButton.icon(
          onPressed: () => context.go('/my-loans'),
          icon: const Icon(Icons.bookmark_outline),
          label: const Text('Мои выдачи'),
        ),
      if (auth.can(Operation.issueLoan))
        FilledButton.icon(
          onPressed: () => context.go('/desk'),
          icon: const Icon(Icons.point_of_sale_outlined),
          label: const Text('Стол выдачи'),
        ),
      if (auth.can(Operation.manageCatalogs)) ...[
        FilledButton.icon(
          onPressed: () => context.go('/authors'),
          icon: const Icon(Icons.people_alt_outlined),
          label: const Text('Авторы'),
        ),
        FilledButton.icon(
          onPressed: () => context.go('/genres'),
          icon: const Icon(Icons.category_outlined),
          label: const Text('Жанры'),
        ),
        FilledButton.icon(
          onPressed: () => context.go('/publishers'),
          icon: const Icon(Icons.business_outlined),
          label: const Text('Издательства'),
        ),
      ],
      if (auth.can(Operation.manageReaders))
        FilledButton.icon(
          onPressed: () => context.go('/readers'),
          icon: const Icon(Icons.badge_outlined),
          label: const Text('Читатели'),
        ),
      if (auth.can(Operation.manageUsers))
        FilledButton.icon(
          onPressed: () => context.go('/admin/users'),
          icon: const Icon(Icons.manage_accounts_outlined),
          label: const Text('Пользователи'),
        ),
      if (auth.can(Operation.viewStats))
        FilledButton.icon(
          onPressed: () => context.go('/admin/stats'),
          icon: const Icon(Icons.insights_outlined),
          label: const Text('Статистика'),
        ),
    ];

    return Scaffold(
      appBar: buildAppBar(context, 'Главная', showBack: false),
      body: NarrowBody(
        maxWidth: columns == 1 ? 520 : 720,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Учебная библиотека',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Вы вошли как ${auth.user?.displayName ?? ''} (${auth.uiRole.title}).',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (columns == 1)
              for (final button in buttons) ...[
                button,
                const SizedBox(height: 12),
              ]
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final button in buttons)
                    SizedBox(width: 340, child: button),
                ],
              ),
            const SizedBox(height: 20),
            Text(
              'Инструменты из практики 1',
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go('/calculator'),
              icon: const Icon(Icons.calculate),
              label: const Text('Калькулятор'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go('/converter'),
              icon: const Icon(Icons.currency_exchange),
              label: const Text('Конвертер валют'),
            ),
          ],
        ),
      ),
    );
  }
}
