import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/breakpoints.dart';
import '../data/catalog_cache.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import '../state/book_list_notifier.dart';
import '../widgets/app_chrome.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_extras.dart';

class BooksScreen extends StatefulWidget {
  final BookQuery query;

  const BooksScreen({super.key, required this.query});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  late final TextEditingController _search;
  late final TextEditingController _yearFrom;
  late final TextEditingController _yearTo;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.query.search);
    _yearFrom = TextEditingController(text: widget.query.yearFrom?.toString() ?? '');
    _yearTo = TextEditingController(text: widget.query.yearTo?.toString() ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BookListNotifier>().applyQuery(widget.query);
      }
    });
  }

  @override
  void didUpdateWidget(covariant BooksScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      if (_search.text != widget.query.search) {
        _search.text = widget.query.search;
      }
      final fromText = widget.query.yearFrom?.toString() ?? '';
      final toText = widget.query.yearTo?.toString() ?? '';
      if (_yearFrom.text != fromText) _yearFrom.text = fromText;
      if (_yearTo.text != toText) _yearTo.text = toText;
      context.read<BookListNotifier>().applyQuery(widget.query);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _yearFrom.dispose();
    _yearTo.dispose();
    super.dispose();
  }

  void _go(BookQuery query) => context.go(query.toLocation());

  void _debounced(VoidCallback action) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), action);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BookListNotifier>();
    final cache = context.watch<CatalogCache>();
    final compact = isCompact(context);
    final genres = cache.genres.where((g) => !g.isDeleted).toList();
    final publishers = cache.publishers.where((p) => !p.isDeleted).toList();

    return Scaffold(
      appBar: buildAppBar(context, 'Каталог книг'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/books/new'),
        tooltip: 'Новая книга',
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
                      labelText: 'Поиск по названию или ISBN',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) => _debounced(
                      () => _go(widget.query.copyWith(search: value)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<int?>(
                    key: ValueKey('genre-${widget.query.genreId}'),
                    isExpanded: true,
                    initialValue: widget.query.genreId != null &&
                            genres.any((g) => g.id == widget.query.genreId)
                        ? widget.query.genreId
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Жанр',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Все жанры')),
                      for (final genre in genres)
                        DropdownMenuItem(value: genre.id, child: Text(genre.name)),
                    ],
                    onChanged: (value) => _go(widget.query.copyWith(genreId: value)),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<int?>(
                    key: ValueKey('publisher-${widget.query.publisherId}'),
                    isExpanded: true,
                    initialValue: widget.query.publisherId != null &&
                            publishers.any((p) => p.id == widget.query.publisherId)
                        ? widget.query.publisherId
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Издательство',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Все издательства')),
                      for (final publisher in publishers)
                        DropdownMenuItem(value: publisher.id, child: Text(publisher.name)),
                    ],
                    onChanged: (value) => _go(widget.query.copyWith(publisherId: value)),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _yearFrom,
                    decoration: const InputDecoration(
                      labelText: 'Год от',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) => _debounced(
                      () => _go(widget.query.copyWith(yearFrom: int.tryParse(value))),
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _yearTo,
                    decoration: const InputDecoration(
                      labelText: 'Год до',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) => _debounced(
                      () => _go(widget.query.copyWith(yearTo: int.tryParse(value))),
                    ),
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
                        title: 'Удалить выбранные',
                        message:
                            'Будет выполнено логическое удаление ${notifier.selected.length} записей. Их можно восстановить.',
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
                    ? _BookCards(notifier: notifier, cache: cache)
                    : EntityTable<Book>(
                        items: notifier.result.items,
                        idOf: (b) => b.id,
                        selected: notifier.selected,
                        onToggleSelect: notifier.toggleSelection,
                        sortField: notifier.query.sortField,
                        sortAscending: notifier.query.sortAscending,
                        isDeleted: (b) => b.isDeleted,
                        onSort: (field) => _go(
                          widget.query.copyWith(
                            sortField: field,
                            sortAscending: field == widget.query.sortField
                                ? !widget.query.sortAscending
                                : true,
                          ),
                        ),
                        columns: [
                          TableColumnSpec(label: 'Название', sortField: 'title', build: (b) => Text(b.title)),
                          TableColumnSpec(label: 'ISBN', build: (b) => Text(b.isbn)),
                          TableColumnSpec(label: 'Год', sortField: 'year', numeric: true, build: (b) => Text('${b.year}')),
                          TableColumnSpec(label: 'Страниц', sortField: 'pages', numeric: true, build: (b) => Text('${b.pages}')),
                          TableColumnSpec(label: 'Издательство', build: (b) => Text(cache.publisherNameOf(b.publisherId))),
                          TableColumnSpec(label: 'Жанры', build: (b) => Text(cache.genreNamesOf(b.genreIds))),
                        ],
                        actions: (b) => _bookActions(context, notifier, b),
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

class _BookCards extends StatelessWidget {
  final BookListNotifier notifier;
  final CatalogCache cache;

  const _BookCards({required this.notifier, required this.cache});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: notifier.result.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final book = notifier.result.items[index];
        return Card(
          color: book.isDeleted
              ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4)
              : null,
          child: ListTile(
            leading: Checkbox(
              value: notifier.selected.contains(book.id),
              onChanged: (_) => notifier.toggleSelection(book.id),
            ),
            title: Text(
              book.title,
              style: book.isDeleted
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
            ),
            subtitle: Text('${book.year} · ${cache.publisherNameOf(book.publisherId)} · ${cache.genreNamesOf(book.genreIds)}'),
            trailing: Wrap(children: _bookActions(context, notifier, book)),
            onTap: () => context.go('/books/${book.id}'),
          ),
        );
      },
    );
  }
}

List<Widget> _bookActions(BuildContext context, BookListNotifier notifier, Book book) {
  return [
    IconButton(
      tooltip: 'Карточка',
      icon: const Icon(Icons.visibility_outlined),
      onPressed: () => context.go('/books/${book.id}'),
    ),
    IconButton(
      tooltip: 'Изменить',
      icon: const Icon(Icons.edit_outlined),
      onPressed: () => context.go('/books/${book.id}/edit'),
    ),
    if (book.isDeleted)
      IconButton(
        tooltip: 'Восстановить',
        icon: const Icon(Icons.restore),
        onPressed: () => notifier.restore(book.id),
      )
    else
      IconButton(
        tooltip: 'Логическое удаление',
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          final ok = await confirmAction(
            context,
            title: 'Логическое удаление',
            message: 'Запись «${book.title}» исчезнет из обычного списка, но её можно будет восстановить.',
          );
          if (ok) await notifier.softDelete(book.id);
        },
      ),
    IconButton(
      tooltip: 'Физическое удаление',
      icon: const Icon(Icons.delete_forever),
      onPressed: () async {
        final ok = await confirmAction(
          context,
          title: 'Физическое удаление',
          message: 'Запись «${book.title}» будет удалена навсегда. Восстановить её нельзя.',
        );
        if (ok) await notifier.hardDelete(book.id);
      },
    ),
  ];
}
