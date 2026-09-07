import '../data/library_store.dart';
import '../models/author.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import '../models/reader.dart';

abstract interface class GenreRepository {
  Future<PageResult<Genre>> find(CatalogQuery query);
  Future<Genre?> findById(int id);
  Future<Genre> create(Genre genre);
  Future<Genre> update(Genre genre);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

abstract interface class PublisherRepository {
  Future<PageResult<Publisher>> find(CatalogQuery query);
  Future<Publisher?> findById(int id);
  Future<Publisher> create(Publisher publisher);
  Future<Publisher> update(Publisher publisher);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

abstract interface class ReaderRepository {
  Future<PageResult<Reader>> find(CatalogQuery query);
  Future<Reader?> findById(int id);
  Future<Reader> create(Reader reader);
  Future<Reader> update(Reader reader);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

class InMemoryGenreRepository implements GenreRepository {
  final LibraryStore store;

  InMemoryGenreRepository(this.store);

  @override
  Future<PageResult<Genre>> find(CatalogQuery q) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (q.fail) throw StateError('учебная ошибка загрузки');
    var rows = store.genres.where((g) => q.includeDeleted || !g.isDeleted).toList();
    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows.where((g) => g.name.toLowerCase().contains(needle)).toList();
    }
    rows.sort((a, b) {
      final result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return q.sortAscending ? result : -result;
    });
    return paginate(rows, q.page, q.size);
  }

  @override
  Future<Genre?> findById(int id) async {
    for (final item in store.genres) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<Genre> create(Genre genre) async {
    final created = Genre(id: store.nextGenreId++, name: genre.name, description: genre.description);
    store.genres.add(created);
    await store.persist();
    return created;
  }

  @override
  Future<Genre> update(Genre genre) async {
    final i = store.genres.indexWhere((g) => g.id == genre.id);
    if (i == -1) throw StateError('Жанр ${genre.id} не найден');
    store.genres[i] = genre;
    await store.persist();
    return genre;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = store.genres.indexWhere((g) => g.id == id);
    if (i == -1) throw StateError('Жанр $id не найден');
    store.genres[i] = store.genres[i].copyWith(deletedAt: DateTime.now());
    await store.persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    store.genres.removeWhere((g) => g.id == id);
    await store.persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = store.genres.indexWhere((g) => g.id == id);
    if (i == -1) throw StateError('Жанр $id не найден');
    store.genres[i] = store.genres[i].copyWith(clearDeletedAt: true);
    await store.persist();
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = store.genres.indexWhere((g) => g.id == id && !g.isDeleted);
      if (i != -1) {
        store.genres[i] = store.genres[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    await store.persist();
    return count;
  }
}

class InMemoryPublisherRepository implements PublisherRepository {
  final LibraryStore store;

  InMemoryPublisherRepository(this.store);

  @override
  Future<PageResult<Publisher>> find(CatalogQuery q) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (q.fail) throw StateError('учебная ошибка загрузки');
    var rows = store.publishers.where((p) => q.includeDeleted || !p.isDeleted).toList();
    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((p) => p.name.toLowerCase().contains(needle) || p.city.toLowerCase().contains(needle))
          .toList();
    }
    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'city' => a.city.compareTo(b.city),
        'foundedYear' => a.foundedYear.compareTo(b.foundedYear),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });
    return paginate(rows, q.page, q.size);
  }

  @override
  Future<Publisher?> findById(int id) async {
    for (final item in store.publishers) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<Publisher> create(Publisher publisher) async {
    final created = Publisher(
      id: store.nextPublisherId++,
      name: publisher.name,
      city: publisher.city,
      foundedYear: publisher.foundedYear,
    );
    store.publishers.add(created);
    await store.persist();
    return created;
  }

  @override
  Future<Publisher> update(Publisher publisher) async {
    final i = store.publishers.indexWhere((p) => p.id == publisher.id);
    if (i == -1) throw StateError('Издательство ${publisher.id} не найдено');
    store.publishers[i] = publisher;
    await store.persist();
    return publisher;
  }

  @override
  Future<void> softDelete(int id) async {
    final linked = store.booksCountForPublisher(id);
    if (linked > 0) {
      throw RelationException('Нельзя удалить издательство: на него ссылаются $linked книг(и).');
    }
    final i = store.publishers.indexWhere((p) => p.id == id);
    if (i == -1) throw StateError('Издательство $id не найдено');
    store.publishers[i] = store.publishers[i].copyWith(deletedAt: DateTime.now());
    await store.persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    final linked = store.booksCountForPublisher(id);
    if (linked > 0) {
      throw RelationException('Нельзя удалить издательство: на него ссылаются $linked книг(и).');
    }
    store.publishers.removeWhere((p) => p.id == id);
    await store.persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = store.publishers.indexWhere((p) => p.id == id);
    if (i == -1) throw StateError('Издательство $id не найдено');
    store.publishers[i] = store.publishers[i].copyWith(clearDeletedAt: true);
    await store.persist();
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    for (final id in ids) {
      final linked = store.booksCountForPublisher(id);
      if (linked > 0) {
        throw RelationException('Нельзя удалить издательство: на него ссылаются $linked книг(и).');
      }
    }
    var count = 0;
    for (final id in ids) {
      final i = store.publishers.indexWhere((p) => p.id == id && !p.isDeleted);
      if (i != -1) {
        store.publishers[i] = store.publishers[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    await store.persist();
    return count;
  }
}

class InMemoryReaderRepository implements ReaderRepository {
  final LibraryStore store;

  InMemoryReaderRepository(this.store);

  @override
  Future<PageResult<Reader>> find(CatalogQuery q) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (q.fail) throw StateError('учебная ошибка загрузки');
    var rows = store.readers.where((r) => q.includeDeleted || !r.isDeleted).toList();
    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where(
            (r) =>
                r.lastName.toLowerCase().contains(needle) ||
                r.firstName.toLowerCase().contains(needle) ||
                r.email.toLowerCase().contains(needle),
          )
          .toList();
    }
    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'email' => a.email.compareTo(b.email),
        _ => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });
    return paginate(rows, q.page, q.size);
  }

  @override
  Future<Reader?> findById(int id) async {
    for (final item in store.readers) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<Reader> create(Reader reader) async {
    final created = Reader(
      id: store.nextReaderId++,
      lastName: reader.lastName,
      firstName: reader.firstName,
      email: reader.email,
      phone: reader.phone,
      card: reader.card,
    );
    store.readers.add(created);
    await store.persist();
    return created;
  }

  @override
  Future<Reader> update(Reader reader) async {
    final i = store.readers.indexWhere((r) => r.id == reader.id);
    if (i == -1) throw StateError('Читатель ${reader.id} не найден');
    store.readers[i] = reader;
    await store.persist();
    return reader;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = store.readers.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('Читатель $id не найден');
    store.readers[i] = store.readers[i].copyWith(deletedAt: DateTime.now());
    await store.persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    store.readers.removeWhere((r) => r.id == id);
    await store.persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = store.readers.indexWhere((r) => r.id == id);
    if (i == -1) throw StateError('Читатель $id не найден');
    store.readers[i] = store.readers[i].copyWith(clearDeletedAt: true);
    await store.persist();
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = store.readers.indexWhere((r) => r.id == id && !r.isDeleted);
      if (i != -1) {
        store.readers[i] = store.readers[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    await store.persist();
    return count;
  }
}
