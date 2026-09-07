import '../data/library_store.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import 'book_repository.dart';

class InMemoryBookRepository implements BookRepository {
  final LibraryStore store;

  InMemoryBookRepository(this.store);

  Future<void> _delay() => Future<void>.delayed(const Duration(milliseconds: 250));

  @override
  Future<PageResult<Book>> find(BookQuery q) async {
    await _delay();
    if (q.fail) throw StateError('учебная ошибка загрузки');

    var rows = store.books.where((b) => q.includeDeleted || !b.isDeleted).toList();
    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where(
            (b) =>
                b.title.toLowerCase().contains(needle) ||
                b.isbn.toLowerCase().contains(needle),
          )
          .toList();
    }
    if (q.genreId != null) {
      rows = rows.where((b) => b.genreIds.contains(q.genreId)).toList();
    }
    if (q.publisherId != null) {
      rows = rows.where((b) => b.publisherId == q.publisherId).toList();
    }
    if (q.yearFrom != null) {
      rows = rows.where((b) => b.year >= q.yearFrom!).toList();
    }
    if (q.yearTo != null) {
      rows = rows.where((b) => b.year <= q.yearTo!).toList();
    }
    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'year' => a.year.compareTo(b.year),
        'pages' => a.pages.compareTo(b.pages),
        _ => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });
    return paginate(rows, q.page, q.size);
  }

  @override
  Future<Book?> findById(int id) async {
    await _delay();
    for (final book in store.books) {
      if (book.id == id) return book;
    }
    return null;
  }

  @override
  Future<Book> create(Book book) async {
    final created = Book(
      id: store.nextBookId++,
      title: book.title,
      isbn: book.isbn,
      year: book.year,
      pages: book.pages,
      publisherId: book.publisherId,
      authorIds: book.authorIds,
      genreIds: book.genreIds,
      copiesTotal: book.copiesTotal,
      copiesAvailable: book.copiesAvailable,
    );
    store.books.add(created);
    await store.persist();
    return created;
  }

  @override
  Future<Book> update(Book book) async {
    final i = store.books.indexWhere((b) => b.id == book.id);
    if (i == -1) throw StateError('Книга ${book.id} не найдена');
    store.books[i] = book;
    await store.persist();
    return book;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = store.books.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Книга $id не найдена');
    store.books[i] = store.books[i].copyWith(deletedAt: DateTime.now());
    await store.persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    store.books.removeWhere((b) => b.id == id);
    await store.persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = store.books.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Книга $id не найдена');
    store.books[i] = store.books[i].copyWith(clearDeletedAt: true);
    await store.persist();
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = store.books.indexWhere((b) => b.id == id && !b.isDeleted);
      if (i != -1) {
        store.books[i] = store.books[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    await store.persist();
    return count;
  }
}
