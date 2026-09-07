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
              'Списки, фильтры и пагинация синхронизируются с адресной строкой.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/books'),
              icon: const Icon(Icons.menu_book),
              label: const Text('Каталог книг'),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go('/authors'),
              icon: const Icon(Icons.people_alt_outlined),
              label: const Text('Авторы'),
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
