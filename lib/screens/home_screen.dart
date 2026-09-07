import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_chrome.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Главная', showBack: false),
      body: NarrowBody(
        maxWidth: 520,
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
              'Каталог читается с учебного REST API. Адрес сервера задаётся через --dart-define=API_BASE_URL.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/books'),
              icon: const Icon(Icons.menu_book),
              label: const Text('Каталог книг'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.go('/authors'),
              icon: const Icon(Icons.people_alt_outlined),
              label: const Text('Авторы'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.go('/genres'),
              icon: const Icon(Icons.category_outlined),
              label: const Text('Жанры'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.go('/publishers'),
              icon: const Icon(Icons.business_outlined),
              label: const Text('Издательства'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.go('/readers'),
              icon: const Icon(Icons.badge_outlined),
              label: const Text('Читатели'),
            ),
            const SizedBox(height: 32),
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
