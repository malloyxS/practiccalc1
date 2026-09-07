import 'package:flutter/material.dart';

import '../models/page_result.dart';

class PaginationBar extends StatelessWidget {
  final PageResult<dynamic> result;
  final ValueChanged<int> onPage;
  final ValueChanged<int> onSize;

  const PaginationBar({
    super.key,
    required this.result,
    required this.onPage,
    required this.onSize,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Всего: ${result.total}'),
        IconButton(
          tooltip: 'Первая',
          onPressed: result.hasPrevious ? () => onPage(1) : null,
          icon: const Icon(Icons.first_page),
        ),
        IconButton(
          tooltip: 'Предыдущая',
          onPressed: result.hasPrevious ? () => onPage(result.page - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('Стр. ${result.page} из ${result.totalPages}'),
        IconButton(
          tooltip: 'Следующая',
          onPressed: result.hasNext ? () => onPage(result.page + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
        IconButton(
          tooltip: 'Последняя',
          onPressed: result.hasNext ? () => onPage(result.totalPages) : null,
          icon: const Icon(Icons.last_page),
        ),
        const SizedBox(width: 8),
        const Text('На странице'),
        DropdownButton<int>(
          value: const [10, 25, 50].contains(result.size) ? result.size : 10,
          items: const [
            DropdownMenuItem(value: 10, child: Text('10')),
            DropdownMenuItem(value: 25, child: Text('25')),
            DropdownMenuItem(value: 50, child: Text('50')),
          ],
          onChanged: (value) {
            if (value != null) onSize(value);
          },
        ),
      ],
    );
  }
}

class ListStatusView extends StatelessWidget {
  final bool loading;
  final bool empty;
  final String? error;
  final VoidCallback? onRetry;
  final Widget child;
  final String emptyText;

  const ListStatusView({
    super.key,
    required this.loading,
    required this.empty,
    required this.child,
    this.error,
    this.onRetry,
    this.emptyText = 'Ничего не найдено. Измените условия поиска.',
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Повторить')),
            ],
          ),
        ),
      );
    }
    if (empty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 48),
              const SizedBox(height: 12),
              Text(emptyText, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return child;
  }
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      constraints: const BoxConstraints(maxWidth: 420),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Подтвердить'),
        ),
      ],
    ),
  );
  return result ?? false;
}
