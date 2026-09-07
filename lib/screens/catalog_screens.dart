import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../core/breakpoints.dart';
import '../data/catalog_cache.dart';
import '../data/library_store.dart';
import '../models/author.dart';
import '../models/book_query.dart';
import '../models/reader.dart';
import '../state/book_list_notifier.dart';
import '../state/catalog_notifiers.dart';
import '../widgets/app_chrome.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_extras.dart';

class GenresScreen extends StatefulWidget {
  final CatalogQuery query;

  const GenresScreen({super.key, required this.query});

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  late final TextEditingController _search;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.query.search);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<GenreListNotifier>().applyQuery(widget.query);
    });
  }

  @override
  void didUpdateWidget(covariant GenresScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      if (_search.text != widget.query.search) _search.text = widget.query.search;
      context.read<GenreListNotifier>().applyQuery(widget.query);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _go(CatalogQuery query) => context.go(query.toLocation('/genres'));

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<GenreListNotifier>();
    final compact = isCompact(context);
    return Scaffold(
      appBar: buildAppBar(context, 'Жанры'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/genres/new'),
        tooltip: 'Новый жанр',
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ListFilters(
              search: _search,
              searchLabel: 'Поиск по названию',
              includeDeleted: widget.query.includeDeleted,
              hasSelection: notifier.hasSelection,
              selectedCount: notifier.selected.length,
              onSearch: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), () {
                  _go(widget.query.copyWith(search: value));
                });
              },
              onDeleted: (value) => _go(widget.query.copyWith(includeDeleted: value)),
              onDeleteSelected: () async {
                final ok = await confirmAction(
                  context,
                  title: 'Удалить выбранные',
                  message: 'Логическое удаление ${notifier.selected.length} жанров.',
                );
                if (ok) await notifier.deleteSelected();
              },
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
                          final genre = notifier.result.items[index];
                          return Card(
                            color: genre.isDeleted
                                ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4)
                                : null,
                            child: ListTile(
                              leading: Checkbox(
                                value: notifier.selected.contains(genre.id),
                                onChanged: (_) => notifier.toggleSelection(genre.id),
                              ),
                              title: Text(
                                genre.name,
                                style: genre.isDeleted
                                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                                    : null,
                              ),
                              subtitle: Text(genre.description.isEmpty ? 'Без описания' : genre.description),
                              trailing: Wrap(children: _genreActions(context, notifier, genre)),
                            ),
                          );
                        },
                      )
                    : EntityTable<Genre>(
                        items: notifier.result.items,
                        idOf: (g) => g.id,
                        selected: notifier.selected,
                        onToggleSelect: notifier.toggleSelection,
                        sortField: notifier.query.sortField,
                        sortAscending: notifier.query.sortAscending,
                        isDeleted: (g) => g.isDeleted,
                        onSort: (field) => _go(
                          widget.query.copyWith(
                            sortField: field,
                            sortAscending: field == widget.query.sortField ? !widget.query.sortAscending : true,
                          ),
                        ),
                        columns: [
                          TableColumnSpec(label: 'Название', sortField: 'name', build: (g) => Text(g.name)),
                          TableColumnSpec(
                            label: 'Описание',
                            build: (g) => Text(g.description.isEmpty ? '—' : g.description),
                          ),
                        ],
                        actions: (g) => _genreActions(context, notifier, g),
                      ),
              ),
            ),
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

class PublishersScreen extends StatefulWidget {
  final CatalogQuery query;

  const PublishersScreen({super.key, required this.query});

  @override
  State<PublishersScreen> createState() => _PublishersScreenState();
}

class _PublishersScreenState extends State<PublishersScreen> {
  late final TextEditingController _search;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.query.search);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PublisherListNotifier>().applyQuery(widget.query);
    });
  }

  @override
  void didUpdateWidget(covariant PublishersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      if (_search.text != widget.query.search) _search.text = widget.query.search;
      context.read<PublisherListNotifier>().applyQuery(widget.query);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _go(CatalogQuery query) => context.go(query.toLocation('/publishers'));

  Future<void> _guarded(Future<void> Function() action) async {
    try {
      await action();
    } on ConflictException catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Удаление запрещено'),
          content: Text(e.message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
    } on RelationException catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Удаление запрещено'),
          content: Text(e.message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PublisherListNotifier>();
    final cache = context.watch<CatalogCache>();
    final compact = isCompact(context);
    return Scaffold(
      appBar: buildAppBar(context, 'Издательства'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/publishers/new'),
        tooltip: 'Новое издательство',
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ListFilters(
              search: _search,
              searchLabel: 'Поиск по названию или городу',
              includeDeleted: widget.query.includeDeleted,
              hasSelection: notifier.hasSelection,
              selectedCount: notifier.selected.length,
              onSearch: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), () {
                  _go(widget.query.copyWith(search: value));
                });
              },
              onDeleted: (value) => _go(widget.query.copyWith(includeDeleted: value)),
              onDeleteSelected: () async {
                final ok = await confirmAction(
                  context,
                  title: 'Удалить выбранные',
                  message: 'Логическое удаление выбранных издательств.',
                );
                if (ok) await _guarded(notifier.deleteSelected);
              },
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
                          final publisher = notifier.result.items[index];
                          return Card(
                            color: publisher.isDeleted
                                ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4)
                                : null,
                            child: ListTile(
                              leading: Checkbox(
                                value: notifier.selected.contains(publisher.id),
                                onChanged: (_) => notifier.toggleSelection(publisher.id),
                              ),
                              title: Text(publisher.name),
                              subtitle: Text(
                                '${publisher.city}, ${publisher.foundedYear} · книг: ${cache.booksCountForPublisher(publisher.id)}',
                              ),
                              trailing: Wrap(children: _publisherActions(context, notifier, publisher, _guarded)),
                            ),
                          );
                        },
                      )
                    : EntityTable<Publisher>(
                        items: notifier.result.items,
                        idOf: (p) => p.id,
                        selected: notifier.selected,
                        onToggleSelect: notifier.toggleSelection,
                        sortField: notifier.query.sortField,
                        sortAscending: notifier.query.sortAscending,
                        isDeleted: (p) => p.isDeleted,
                        onSort: (field) => _go(
                          widget.query.copyWith(
                            sortField: field,
                            sortAscending: field == widget.query.sortField ? !widget.query.sortAscending : true,
                          ),
                        ),
                        columns: [
                          TableColumnSpec(label: 'Название', sortField: 'name', build: (p) => Text(p.name)),
                          TableColumnSpec(label: 'Город', sortField: 'city', build: (p) => Text(p.city)),
                          TableColumnSpec(
                            label: 'Год основания',
                            sortField: 'foundedYear',
                            numeric: true,
                            build: (p) => Text('${p.foundedYear}'),
                          ),
                          TableColumnSpec(
                            label: 'Книг',
                            numeric: true,
                            build: (p) => Text('${cache.booksCountForPublisher(p.id)}'),
                          ),
                        ],
                        actions: (p) => _publisherActions(context, notifier, p, _guarded),
                      ),
              ),
            ),
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

class ReadersScreen extends StatefulWidget {
  final CatalogQuery query;

  const ReadersScreen({super.key, required this.query});

  @override
  State<ReadersScreen> createState() => _ReadersScreenState();
}

class _ReadersScreenState extends State<ReadersScreen> {
  late final TextEditingController _search;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.query.search);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ReaderListNotifier>().applyQuery(widget.query);
    });
  }

  @override
  void didUpdateWidget(covariant ReadersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      if (_search.text != widget.query.search) _search.text = widget.query.search;
      context.read<ReaderListNotifier>().applyQuery(widget.query);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _go(CatalogQuery query) => context.go(query.toLocation('/readers', defaultSort: 'lastName'));

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ReaderListNotifier>();
    final compact = isCompact(context);
    return Scaffold(
      appBar: buildAppBar(context, 'Читатели'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/readers/new'),
        tooltip: 'Новый читатель',
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ListFilters(
              search: _search,
              searchLabel: 'Поиск по фамилии или email',
              includeDeleted: widget.query.includeDeleted,
              hasSelection: notifier.hasSelection,
              selectedCount: notifier.selected.length,
              onSearch: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), () {
                  _go(widget.query.copyWith(search: value));
                });
              },
              onDeleted: (value) => _go(widget.query.copyWith(includeDeleted: value)),
              onDeleteSelected: () async {
                final ok = await confirmAction(
                  context,
                  title: 'Удалить выбранных',
                  message: 'Логическое удаление ${notifier.selected.length} читателей.',
                );
                if (ok) await notifier.deleteSelected();
              },
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
                          final reader = notifier.result.items[index];
                          return Card(
                            color: reader.isDeleted
                                ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4)
                                : null,
                            child: ListTile(
                              leading: Checkbox(
                                value: notifier.selected.contains(reader.id),
                                onChanged: (_) => notifier.toggleSelection(reader.id),
                              ),
                              title: Text(reader.fullName),
                              subtitle: Text('${reader.email} · билет ${reader.card.number}'),
                              trailing: Wrap(children: _readerActions(context, notifier, reader)),
                            ),
                          );
                        },
                      )
                    : EntityTable<Reader>(
                        items: notifier.result.items,
                        idOf: (r) => r.id,
                        selected: notifier.selected,
                        onToggleSelect: notifier.toggleSelection,
                        sortField: notifier.query.sortField,
                        sortAscending: notifier.query.sortAscending,
                        isDeleted: (r) => r.isDeleted,
                        onSort: (field) => _go(
                          widget.query.copyWith(
                            sortField: field,
                            sortAscending: field == widget.query.sortField ? !widget.query.sortAscending : true,
                          ),
                        ),
                        columns: [
                          TableColumnSpec(label: 'Фамилия', sortField: 'lastName', build: (r) => Text(r.lastName)),
                          TableColumnSpec(label: 'Имя', build: (r) => Text(r.firstName)),
                          TableColumnSpec(label: 'Email', sortField: 'email', build: (r) => Text(r.email)),
                          TableColumnSpec(label: 'Телефон', build: (r) => Text(r.phone)),
                          TableColumnSpec(label: 'Билет', build: (r) => Text(r.card.number)),
                          TableColumnSpec(
                            label: 'Билет активен',
                            build: (r) => Text(r.card.active ? 'да' : 'нет'),
                          ),
                        ],
                        actions: (r) => _readerActions(context, notifier, r),
                      ),
              ),
            ),
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

class _ListFilters extends StatelessWidget {
  final TextEditingController search;
  final String searchLabel;
  final bool includeDeleted;
  final bool hasSelection;
  final int selectedCount;
  final ValueChanged<String> onSearch;
  final ValueChanged<bool> onDeleted;
  final VoidCallback onDeleteSelected;

  const _ListFilters({
    required this.search,
    required this.searchLabel,
    required this.includeDeleted,
    required this.hasSelection,
    required this.selectedCount,
    required this.onSearch,
    required this.onDeleted,
    required this.onDeleteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: TextField(
            controller: search,
            decoration: InputDecoration(
              labelText: searchLabel,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: onSearch,
          ),
        ),
        FilterChip(
          label: const Text('Показывать удалённые'),
          selected: includeDeleted,
          onSelected: onDeleted,
        ),
        if (hasSelection)
          FilledButton.tonalIcon(
            onPressed: onDeleteSelected,
            icon: const Icon(Icons.delete_outline),
            label: Text('Удалить выбранные ($selectedCount)'),
          ),
      ],
    );
  }
}

List<Widget> _crudActions({
  required bool isDeleted,
  required VoidCallback onEdit,
  required Future<void> Function() onSoft,
  required Future<void> Function() onHard,
  required VoidCallback onRestore,
}) {
  return [
    IconButton(
      tooltip: 'Изменить',
      icon: const Icon(Icons.edit_outlined),
      onPressed: onEdit,
    ),
    if (isDeleted)
      IconButton(tooltip: 'Восстановить', icon: const Icon(Icons.restore), onPressed: onRestore)
    else
      IconButton(tooltip: 'Логическое удаление', icon: const Icon(Icons.delete_outline), onPressed: () async => onSoft()),
    IconButton(
      tooltip: 'Физическое удаление',
      icon: const Icon(Icons.delete_forever),
      onPressed: () async => onHard(),
    ),
  ];
}

List<Widget> _genreActions(BuildContext context, GenreListNotifier notifier, Genre genre) {
  return _crudActions(
    isDeleted: genre.isDeleted,
    onEdit: () => context.go('/genres/${genre.id}/edit'),
    onSoft: () async {
      final ok = await confirmAction(
        context,
        title: 'Логическое удаление',
        message: 'Жанр «${genre.name}» исчезнет из обычного списка.',
      );
      if (ok) await notifier.softDelete(genre.id);
    },
    onHard: () async {
      final ok = await confirmAction(
        context,
        title: 'Физическое удаление',
        message: 'Жанр «${genre.name}» будет удалён навсегда.',
      );
      if (ok) await notifier.hardDelete(genre.id);
    },
    onRestore: () => notifier.restore(genre.id),
  );
}

List<Widget> _publisherActions(
  BuildContext context,
  PublisherListNotifier notifier,
  Publisher publisher,
  Future<void> Function(Future<void> Function()) guarded,
) {
  return _crudActions(
    isDeleted: publisher.isDeleted,
    onEdit: () => context.go('/publishers/${publisher.id}/edit'),
    onSoft: () async {
      final ok = await confirmAction(
        context,
        title: 'Логическое удаление',
        message: 'Издательство «${publisher.name}» исчезнет из обычного списка.',
      );
      if (ok) await guarded(() => notifier.softDelete(publisher.id));
    },
    onHard: () async {
      final ok = await confirmAction(
        context,
        title: 'Физическое удаление',
        message: 'Издательство «${publisher.name}» будет удалено навсегда.',
      );
      if (ok) await guarded(() => notifier.hardDelete(publisher.id));
    },
    onRestore: () => notifier.restore(publisher.id),
  );
}

List<Widget> _readerActions(BuildContext context, ReaderListNotifier notifier, Reader reader) {
  return _crudActions(
    isDeleted: reader.isDeleted,
    onEdit: () => context.go('/readers/${reader.id}/edit'),
    onSoft: () async {
      final ok = await confirmAction(
        context,
        title: 'Логическое удаление',
        message: 'Читатель «${reader.fullName}» исчезнет из обычного списка.',
      );
      if (ok) await notifier.softDelete(reader.id);
    },
    onHard: () async {
      final ok = await confirmAction(
        context,
        title: 'Физическое удаление',
        message: 'Читатель «${reader.fullName}» будет удалён навсегда.',
      );
      if (ok) await notifier.hardDelete(reader.id);
    },
    onRestore: () => notifier.restore(reader.id),
  );
}
