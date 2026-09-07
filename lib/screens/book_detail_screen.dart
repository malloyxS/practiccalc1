import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/library_store.dart';
import '../models/author.dart';
import '../models/book.dart';
import '../repositories/author_repository.dart';
import '../repositories/book_repository.dart';
import '../widgets/app_chrome.dart';

class BookDetailScreen extends StatelessWidget {
  final int? id;

  const BookDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    if (id == null) {
      return const _Missing(title: 'Карточка книги', message: 'Некорректный идентификатор.');
    }

    return FutureBuilder<Book?>(
      future: context.read<BookRepository>().findById(id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: buildAppBar(context, 'Карточка книги'),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final book = snapshot.data;
        if (book == null) {
          return const _Missing(title: 'Карточка книги', message: 'Книга не найдена.');
        }
        final store = context.watch<LibraryStore>();
        return Scaffold(
          appBar: buildAppBar(context, book.title),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _InfoRow(label: 'Название', value: book.title),
              _InfoRow(label: 'ISBN', value: book.isbn),
              _InfoRow(label: 'Год', value: '${book.year}'),
              _InfoRow(label: 'Страниц', value: '${book.pages}'),
              _InfoRow(label: 'Издательство', value: store.publisherNameOf(book.publisherId)),
              _InfoRow(label: 'Авторы', value: store.authorNamesOf(book.authorIds)),
              _InfoRow(label: 'Жанры', value: store.genreNamesOf(book.genreIds)),
              _InfoRow(label: 'Экземпляров', value: '${book.copiesAvailable} из ${book.copiesTotal}'),
              _InfoRow(label: 'Статус', value: book.isDeleted ? 'Логически удалена' : 'Активна'),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                children: [
                  FilledButton(
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
      },
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
        final store = context.watch<LibraryStore>();
        final books = store.books.where((b) => b.authorIds.contains(author.id)).toList();
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
