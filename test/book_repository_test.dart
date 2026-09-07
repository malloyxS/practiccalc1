import 'package:flutter_test/flutter_test.dart';

import 'package:calc_web/models/book_query.dart';
import 'package:calc_web/repositories/in_memory_book_repository.dart';

void main() {
  test('deleteMany помечает только активные записи', () async {
    final repo = InMemoryBookRepository();
    final count = await repo.deleteMany([1, 2, 1]);
    expect(count, 2);

    final hidden = await repo.find(const BookQuery());
    expect(hidden.items.any((b) => b.id == 1), isFalse);

    final withDeleted = await repo.find(const BookQuery(includeDeleted: true, size: 50));
    expect(withDeleted.items.any((b) => b.id == 1 && b.isDeleted), isTrue);
  });

  test('поиск, фильтры и пагинация работают вместе', () async {
    final repo = InMemoryBookRepository();
    final page = await repo.find(
      const BookQuery(
        search: 'деньги',
        genreId: 4,
        yearFrom: 2018,
        yearTo: 2024,
        sortField: 'year',
        sortAscending: false,
        page: 1,
        size: 10,
      ),
    );
    expect(page.total, greaterThan(0));
    expect(page.items.every((b) => b.title.toLowerCase().contains('деньги')), isTrue);
    expect(page.items.every((b) => b.genreIds.contains(4)), isTrue);
  });

  test('BookQuery восстанавливается из адреса', () {
    final uri = Uri.parse(
      '/books?search=война&genreId=2&sort=year,desc&page=3&includeDeleted=1',
    );
    final query = BookQuery.fromUri(uri);
    expect(query.search, 'война');
    expect(query.genreId, 2);
    expect(query.sortField, 'year');
    expect(query.sortAscending, isFalse);
    expect(query.page, 3);
    expect(query.includeDeleted, isTrue);
    expect(Uri.parse(query.toLocation()).queryParameters['search'], 'война');
  });
}
