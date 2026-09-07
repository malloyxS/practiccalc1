import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../models/reader.dart';
import 'seed_data.dart' as seed;

class RelationException implements Exception {
  final String message;

  RelationException(this.message);

  @override
  String toString() => message;
}

class LibraryStore extends ChangeNotifier {
  static const booksKey = 'books_v1';
  static const authorsKey = 'authors_v1';
  static const genresKey = 'genres_v1';
  static const publishersKey = 'publishers_v1';
  static const readersKey = 'readers_v1';

  final SharedPreferences? _prefs;

  List<Book> books = [];
  List<Author> authors = [];
  List<Genre> genres = [];
  List<Publisher> publishers = [];
  List<Reader> readers = [];

  int nextBookId = 1;
  int nextAuthorId = 1;
  int nextGenreId = 1;
  int nextPublisherId = 1;
  int nextReaderId = 1;

  String? restoreMessage;

  LibraryStore._(this._prefs);

  factory LibraryStore.memory() {
    final store = LibraryStore._(null);
    store._seed();
    return store;
  }

  static Future<LibraryStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final store = LibraryStore._(prefs);
    store.restore();
    return store;
  }

  void _seed() {
    books = [...seed.seedBooks];
    authors = [...seed.seedAuthors];
    genres = [...seed.genres];
    publishers = [...seed.publishers];
    readers = [...seed.seedReaders];
    _refreshIds();
  }

  void _refreshIds() {
    nextBookId = _nextId(books.map((e) => e.id));
    nextAuthorId = _nextId(authors.map((e) => e.id));
    nextGenreId = _nextId(genres.map((e) => e.id));
    nextPublisherId = _nextId(publishers.map((e) => e.id));
    nextReaderId = _nextId(readers.map((e) => e.id));
  }

  int _nextId(Iterable<int> ids) => ids.fold<int>(0, (m, id) => id > m ? id : m) + 1;

  void restore() {
    restoreMessage = null;
    final prefs = _prefs;
    if (prefs == null) {
      _seed();
      return;
    }
    try {
      books = _decode(prefs.getString(booksKey), Book.fromJson, seed.seedBooks);
      authors = _decode(prefs.getString(authorsKey), Author.fromJson, seed.seedAuthors);
      genres = _decode(prefs.getString(genresKey), Genre.fromJson, seed.genres);
      publishers = _decode(prefs.getString(publishersKey), Publisher.fromJson, seed.publishers);
      readers = _decode(prefs.getString(readersKey), Reader.fromJson, seed.seedReaders);
      _refreshIds();
      if (prefs.getString(booksKey) == null) {
        restoreMessage = 'Первый запуск: загружен начальный набор данных.';
        persist();
      }
    } catch (_) {
      _seed();
      restoreMessage =
          'Данные в хранилище были в старом формате. Набор восстановлен из начальных записей (ключи *_v1).';
      persist();
    }
  }

  List<T> _decode<T>(
    String? raw,
    T Function(Map<String, dynamic>) fromJson,
    List<T> fallback,
  ) {
    if (raw == null) return [...fallback];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((item) => fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<void> persist() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(booksKey, jsonEncode(books.map((e) => e.toJson()).toList()));
    await prefs.setString(authorsKey, jsonEncode(authors.map((e) => e.toJson()).toList()));
    await prefs.setString(genresKey, jsonEncode(genres.map((e) => e.toJson()).toList()));
    await prefs.setString(publishersKey, jsonEncode(publishers.map((e) => e.toJson()).toList()));
    await prefs.setString(readersKey, jsonEncode(readers.map((e) => e.toJson()).toList()));
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

  String genreNamesOf(List<int> ids) => ids.map((id) => genreById(id)?.name ?? '$id').join(', ');

  String publisherNameOf(int id) => publisherById(id)?.name ?? '$id';

  String authorNamesOf(List<int> ids) => ids.map((id) => authorById(id)?.fullName ?? '$id').join(', ');

  bool isbnTaken(String isbn, {int? excludeId}) {
    final needle = isbn.trim().toLowerCase();
    return books.any((b) => b.isbn.toLowerCase() == needle && b.id != excludeId);
  }

  bool emailTaken(String email, {int? excludeId}) {
    final needle = email.trim().toLowerCase();
    return readers.any((r) => r.email.toLowerCase() == needle && r.id != excludeId);
  }

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
