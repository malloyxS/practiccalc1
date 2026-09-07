import '../data/library_store.dart';
import '../models/author.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import 'author_repository.dart';

class InMemoryAuthorRepository implements AuthorRepository {
  final LibraryStore store;

  InMemoryAuthorRepository(this.store);

  Future<void> _delay() =>
      Future<void>.delayed(const Duration(milliseconds: 250));

  @override
  Future<PageResult<Author>> find(AuthorQuery q) async {
    await _delay();
    if (q.fail) throw StateError('учебная ошибка загрузки');
    var rows = store.authors
        .where((a) => q.includeDeleted || !a.isDeleted)
        .toList();
    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where(
            (a) =>
                a.lastName.toLowerCase().contains(needle) ||
                a.firstName.toLowerCase().contains(needle) ||
                a.country.toLowerCase().contains(needle),
          )
          .toList();
    }
    if (q.country != null) {
      rows = rows.where((a) => a.country == q.country).toList();
    }
    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'country' => a.country.compareTo(b.country),
        'birthYear' => a.birthYear.compareTo(b.birthYear),
        _ => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });
    return paginate(rows, q.page, q.size);
  }

  @override
  Future<Author?> findById(int id) async {
    for (final author in store.authors) {
      if (author.id == id) return author;
    }
    return null;
  }

  @override
  Future<Author> create(Author author) async {
    final created = Author(
      id: store.nextAuthorId++,
      lastName: author.lastName,
      firstName: author.firstName,
      country: author.country,
      birthYear: author.birthYear,
    );
    store.authors.add(created);
    await store.persist();
    return created;
  }

  @override
  Future<Author> update(Author author) async {
    final i = store.authors.indexWhere((a) => a.id == author.id);
    if (i == -1) throw StateError('Автор ${author.id} не найден');
    store.authors[i] = author;
    await store.persist();
    return author;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = store.authors.indexWhere((a) => a.id == id);
    if (i == -1) throw StateError('Автор $id не найден');
    store.authors[i] = store.authors[i].copyWith(deletedAt: DateTime.now());
    await store.persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    store.authors.removeWhere((a) => a.id == id);
    await store.persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = store.authors.indexWhere((a) => a.id == id);
    if (i == -1) throw StateError('Автор $id не найден');
    store.authors[i] = store.authors[i].copyWith(clearDeletedAt: true);
    await store.persist();
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = store.authors.indexWhere((a) => a.id == id && !a.isDeleted);
      if (i != -1) {
        store.authors[i] = store.authors[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    await store.persist();
    return count;
  }
}
