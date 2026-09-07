import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_chrome.dart';

class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Нет доступа'),
      body: Center(
        child: NarrowBody(
          child: Column(
            children: [
              Icon(
                Icons.lock_outline,
                size: 56,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Для этой страницы нужна другая роль. Клиент остановил переход, чтобы не слать заведомо запрещённый запрос.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('На главную'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
