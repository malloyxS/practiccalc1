import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/breakpoints.dart';
import '../data/catalog_cache.dart';
import '../models/author.dart';
import '../models/book_query.dart';
import '../state/author_list_notifier.dart';
import '../state/book_list_notifier.dart';
import '../widgets/app_chrome.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_extras.dart';

class AuthorsScreen extends StatefulWidget {
  final AuthorQuery query;

  const AuthorsScreen({super.key, required this.query});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  late final TextEditingController _search;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.query.search);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthorListNotifier>().applyQuery(widget.query);
      }
    });
  }

  @override
  void didUpdateWidget(covariant AuthorsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      if (_search.text != widget.query.search) {
        _search.text = widget.query.search;
      }
      context.read<AuthorListNotifier>().applyQuery(widget.query);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _go(AuthorQuery query) => context.go(query.toLocation());

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AuthorListNotifier>();
    final cache = context.watch<CatalogCache>();
    final compact = isCompact(context);
    final countries = cache.authors.map((a) => a.country).toSet().toList()..sort();

    return Scaffold(
      appBar: buildAppBar(context, 'Авторы'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/authors/new'),
        tooltip: 'Новый автор',
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                      labelText: 'Поиск по фамилии или стране',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 350), () {
                        _go(widget.query.copyWith(search: value));
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey('country-${widget.query.country}'),
                    isExpanded: true,
                    initialValue: widget.query.country != null && countries.contains(widget.query.country)
                        ? widget.query.country
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Страна',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Все страны')),
                      for (final country in countries)
                        DropdownMenuItem(value: country, child: Text(country)),
                    ],
                    onChanged: (value) => _go(widget.query.copyWith(country: value)),
                  ),
                ),
                FilterChip(
                  label: const Text('Показывать удалённые'),
                  selected: widget.query.includeDeleted,
                  onSelected: (value) => _go(widget.query.copyWith(includeDeleted: value)),
                ),
                if (notifier.hasSelection)
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      final ok = await confirmAction(
                        context,
                        title: 'Удалить выбранных',
                        message:
                            'Логическое удаление ${notifier.selected.length} авторов. Записи можно восстановить.',
                      );
                      if (ok) await notifier.deleteSelected();
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: Text('Удалить выбранные (${notifier.selected.length})'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListStatusView(
                loading: notifier.status == LoadStatus.loading || notifier.status == LoadStatus.idle,
                empty: notifier.status == LoadStatus.success && notifier.result.items.isEmpty,
                error: notifier.status == LoadStatus.error ? notifier.error : null,
                onRetry: () => _go(widget.query.copyWith(fail: false)),
                child: compact
                    ? ListView.separated(
                        itemCount: notifier.result.items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final author = notifier.result.items[index];
                          return Card(
                            color: author.isDeleted
                                ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4)
                                : null,
                            child: ListTile(
                              leading: Checkbox(
                                value: notifier.selected.contains(author.id),
                                onChanged: (_) => notifier.toggleSelection(author.id),
                              ),
                              title: Text(
                                author.fullName,
                                style: author.isDeleted
                                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                                    : null,
                              ),
                              subtitle: Text('${author.country}, ${author.birthYear}'),
                              trailing: Wrap(children: _authorActions(context, notifier, author)),
                              onTap: () => context.go('/authors/${author.id}'),
                            ),
                          );
                        },
                      )
                    : EntityTable<Author>(
                        items: notifier.result.items,
                        idOf: (a) => a.id,
                        selected: notifier.selected,
                        onToggleSelect: notifier.toggleSelection,
                        sortField: notifier.query.sortField,
                        sortAscending: notifier.query.sortAscending,
                        isDeleted: (a) => a.isDeleted,
                        onSort: (field) => _go(
                          widget.query.copyWith(
                            sortField: field,
                            sortAscending: field == widget.query.sortField
                                ? !widget.query.sortAscending
                                : true,
                          ),
                        ),
                        columns: [
                          TableColumnSpec(label: 'Фамилия', sortField: 'lastName', build: (a) => Text(a.lastName)),
                          TableColumnSpec(label: 'Имя', build: (a) => Text(a.firstName)),
                          TableColumnSpec(label: 'Страна', sortField: 'country', build: (a) => Text(a.country)),
                          TableColumnSpec(
                            label: 'Год рождения',
                            sortField: 'birthYear',
                            numeric: true,
                            build: (a) => Text('${a.birthYear}'),
                          ),
                          TableColumnSpec(
                            label: 'Книг',
                            numeric: true,
                            build: (a) => Text(
                              '${cache.books.where((b) => b.authorIds.contains(a.id) && !b.isDeleted).length}',
                            ),
                          ),
                        ],
                        actions: (a) => _authorActions(context, notifier, a),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            PaginationBar(
              result: notifier.result,
              onPage: (page) => _go(widget.query.copyWith(page: page)),
              onSize: (size) => _go(widget.query.copyWith(size: size)),
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _authorActions(
  BuildContext context,
  AuthorListNotifier notifier,
  Author author,
) {
  return [
    IconButton(
      tooltip: 'Карточка',
      icon: const Icon(Icons.visibility_outlined),
      onPressed: () => context.go('/authors/${author.id}'),
    ),
    IconButton(
      tooltip: 'Изменить',
      icon: const Icon(Icons.edit_outlined),
      onPressed: () => context.go('/authors/${author.id}/edit'),
    ),
    if (author.isDeleted)
      IconButton(
        tooltip: 'Восстановить',
        icon: const Icon(Icons.restore),
        onPressed: () => notifier.restore(author.id),
      )
    else
      IconButton(
        tooltip: 'Логическое удаление',
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          final ok = await confirmAction(
            context,
            title: 'Логическое удаление',
            message:
                'Запись «${author.fullName}» исчезнет из обычного списка, но её можно будет восстановить.',
          );
          if (ok) await notifier.softDelete(author.id);
        },
      ),
    IconButton(
      tooltip: 'Физическое удаление',
      icon: const Icon(Icons.delete_forever),
      onPressed: () async {
        final ok = await confirmAction(
          context,
          title: 'Физическое удаление',
          message: 'Запись «${author.fullName}» будет удалена навсегда.',
        );
        if (ok) await notifier.hardDelete(author.id);
      },
    ),
  ];
}
