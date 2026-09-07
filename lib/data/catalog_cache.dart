import 'package:flutter/foundation.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import '../repositories/author_repository.dart';
import '../repositories/book_repository.dart';
import '../repositories/catalog_repositories.dart';

class CatalogCache extends ChangeNotifier {
  final AuthorRepository _authors;
  final GenreRepository _genres;
  final PublisherRepository _publishers;
  final BookRepository _books;

  CatalogCache({
    required AuthorRepository authors,
    required GenreRepository genres,
    required PublisherRepository publishers,
    required BookRepository books,
  }) : _authors = authors,
       _genres = genres,
       _publishers = publishers,
       _books = books;

  List<Author> authors = [];
  List<Genre> genres = [];
  List<Publisher> publishers = [];
  List<Book> books = [];
  bool loaded = false;

  Future<void> ensureLoaded() async {
    if (loaded) return;
    try {
      await refresh();
    } catch (_) {}
  }

  Future<void> refresh() async {
    final authorPage = await _authors.find(const AuthorQuery(size: 50));
    final genrePage = await _genres.find(const CatalogQuery(size: 50));
    final publisherPage = await _publishers.find(const CatalogQuery(size: 50));
    final bookPage = await _books.find(const BookQuery(size: 100));
    authors = authorPage.items;
    genres = genrePage.items;
    publishers = publisherPage.items;
    books = bookPage.items;
    loaded = true;
    notifyListeners();
  }

  Genre? genreById(int id) {
    for (final item in genres) {
      if (item.id == id) return item;
    }
    return null;
  }

  Publisher? publisherById(int id) {
    for (final item in publishers) {
      if (item.id == id) return item;
    }
    return null;
  }

  Author? authorById(int id) {
    for (final item in authors) {
      if (item.id == id) return item;
    }
    return null;
  }

  String genreNamesOf(List<int> ids) =>
      ids.map((id) => genreById(id)?.name ?? '$id').join(', ');

  String publisherNameOf(int id) => publisherById(id)?.name ?? '$id';

  String authorNamesOf(List<int> ids) =>
      ids.map((id) => authorById(id)?.fullName ?? '$id').join(', ');

  int booksCountForPublisher(int publisherId) =>
      books.where((b) => b.publisherId == publisherId && !b.isDeleted).length;

  List<Author> authorsForPublisher(int? publisherId) {
    final active = authors.where((a) => !a.isDeleted).toList();
    if (publisherId == null) return active;
    final ids = books
        .where((b) => b.publisherId == publisherId)
        .expand((b) => b.authorIds)
        .toSet();
    final filtered = active.where((a) => ids.contains(a.id)).toList();
    return filtered.isEmpty ? active : filtered;
  }

  List<Genre> genresForPublisher(int? publisherId) {
    final active = genres.where((g) => !g.isDeleted).toList();
    if (publisherId == null) return active;
    final ids = books
        .where((b) => b.publisherId == publisherId)
        .expand((b) => b.genreIds)
        .toSet();
    final filtered = active.where((g) => ids.contains(g.id)).toList();
    return filtered.isEmpty ? active : filtered;
  }
}
