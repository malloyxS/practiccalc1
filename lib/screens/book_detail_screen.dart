import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../data/catalog_cache.dart';
import '../models/author.dart';
import '../models/book.dart';
import '../models/role.dart';
import '../repositories/author_repository.dart';
import '../repositories/book_repository.dart';
import '../state/auth_notifier.dart';
import '../widgets/app_chrome.dart';

class BookDetailScreen extends StatefulWidget {
  final int? id;

  const BookDetailScreen({super.key, required this.id});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Book? _book;
  bool _loading = true;
  bool _issuing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (widget.id == null) {
      setState(() {
        _loading = false;
        _error = 'Некорректный идентификатор.';
      });
      return;
    }
    try {
      final book = await context.read<BookRepository>().findById(widget.id!);
      if (!mounted) return;
      setState(() {
        _book = book;
        _loading = false;
        _error = book == null ? 'Книга не найдена.' : null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  Future<void> _issue() async {
    if (_book == null || _issuing) return;
    setState(() => _issuing = true);
    try {
      final updated = await context.read<BookRepository>().issue(_book!.id);
      if (!mounted) return;
      setState(() {
        _book = updated;
        _issuing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Выдан экземпляр. Осталось: ${updated.copiesAvailable}')),
      );
    } on ConflictException catch (e) {
      if (!mounted) return;
      setState(() => _issuing = false);
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Выдача невозможна'),
          content: Text(e.message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _issuing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: buildAppBar(context, 'Карточка книги'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final book = _book;
    if (book == null) {
      return _Missing(title: 'Карточка книги', message: _error ?? 'Книга не найдена.');
    }
    final cache = context.watch<CatalogCache>();
    final auth = context.watch<AuthNotifier>();
    return Scaffold(
      appBar: buildAppBar(context, book.title),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _InfoRow(label: 'Название', value: book.title),
          _InfoRow(label: 'ISBN', value: book.isbn),
          _InfoRow(label: 'Год', value: '${book.year}'),
          _InfoRow(label: 'Страниц', value: '${book.pages}'),
          _InfoRow(label: 'Издательство', value: cache.publisherNameOf(book.publisherId)),
          _InfoRow(label: 'Авторы', value: cache.authorNamesOf(book.authorIds)),
          _InfoRow(label: 'Жанры', value: cache.genreNamesOf(book.genreIds)),
          _InfoRow(label: 'Экземпляров', value: '${book.copiesAvailable} из ${book.copiesTotal}'),
          _InfoRow(label: 'Статус', value: book.isDeleted ? 'Логически удалена' : 'Активна'),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (auth.can(Operation.issueLoan))
                FilledButton(
                  onPressed: _issuing ? null : _issue,
                  child: Text(_issuing ? 'Выдача...' : 'Выдать'),
                ),
              if (auth.can(Operation.manageBooks))
                FilledButton.tonal(
                  onPressed: () => context.go('/books/${book.id}/edit'),
                  child: const Text('Изменить'),
                ),
              OutlinedButton(
                onPressed: () => context.go('/books'),
                child: const Text('К каталогу'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AuthorDetailScreen extends StatelessWidget {
  final int? id;

  const AuthorDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    if (id == null) {
      return const _Missing(title: 'Карточка автора', message: 'Некорректный идентификатор.');
    }

    return FutureBuilder<Author?>(
      future: context.read<AuthorRepository>().findById(id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: buildAppBar(context, 'Карточка автора'),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final author = snapshot.data;
        if (author == null) {
          return const _Missing(title: 'Карточка автора', message: 'Автор не найден.');
        }
        final cache = context.watch<CatalogCache>();
        final books = cache.books.where((b) => b.authorIds.contains(author.id)).toList();
        return Scaffold(
          appBar: buildAppBar(context, author.fullName),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _InfoRow(label: 'Фамилия', value: author.lastName),
              _InfoRow(label: 'Имя', value: author.firstName),
              _InfoRow(label: 'Страна', value: author.country),
              _InfoRow(label: 'Год рождения', value: '${author.birthYear}'),
              _InfoRow(label: 'Статус', value: author.isDeleted ? 'Логически удалён' : 'Активен'),
              const SizedBox(height: 16),
              Text('Книги автора', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final book in books)
                ListTile(
                  title: Text(book.title),
                  subtitle: Text('${book.year}'),
                  onTap: () => context.go('/books/${book.id}'),
                ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                children: [
                  FilledButton(
                    onPressed: () => context.go('/authors/${author.id}/edit'),
                    child: const Text('Изменить'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/authors'),
                    child: const Text('К списку авторов'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _Missing extends StatelessWidget {
  final String title;
  final String message;

  const _Missing({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title),
      body: Center(child: Text(message)),
    );
  }
}
