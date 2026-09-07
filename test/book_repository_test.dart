import 'package:flutter_test/flutter_test.dart';

import 'package:calc_web/core/validators.dart';
import 'package:calc_web/data/library_store.dart';
import 'package:calc_web/models/author.dart';
import 'package:calc_web/models/book.dart';
import 'package:calc_web/models/book_query.dart';
import 'package:calc_web/models/reader.dart';
import 'package:calc_web/repositories/catalog_repositories.dart';
import 'package:calc_web/repositories/in_memory_book_repository.dart';

void main() {
  test('deleteMany помечает только активные записи', () async {
    final repo = InMemoryBookRepository(LibraryStore.memory());
    final count = await repo.deleteMany([1, 2, 1]);
    expect(count, 2);

    final hidden = await repo.find(const BookQuery());
    expect(hidden.items.any((b) => b.id == 1), isFalse);

    final withDeleted = await repo.find(const BookQuery(includeDeleted: true, size: 50));
    expect(withDeleted.items.any((b) => b.id == 1 && b.isDeleted), isTrue);
  });

  test('поиск, фильтры и пагинация работают вместе', () async {
    final repo = InMemoryBookRepository(LibraryStore.memory());
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

  test('ISBN должен быть уникальным', () {
    final store = LibraryStore.memory();
    expect(store.isbnTaken('978-5-17-118365-1'), isTrue);
    expect(store.isbnTaken('978-5-17-118365-1', excludeId: 1), isFalse);
    expect(store.isbnTaken('978-0-00-000000-0'), isFalse);
  });

  test('email читателя должен быть уникальным', () {
    final store = LibraryStore.memory();
    expect(store.emailTaken('ivanov@mail.test'), isTrue);
    expect(store.emailTaken('ivanov@mail.test', excludeId: 1), isFalse);
  });

  test('нельзя удалить издательство, на которое ссылаются книги', () async {
    final store = LibraryStore.memory();
    final repo = InMemoryPublisherRepository(store);
    expect(store.booksCountForPublisher(1), greaterThan(0));
    expect(
      () => repo.hardDelete(1),
      throwsA(isA<RelationException>()),
    );
  });

  test('можно удалить издательство без книг', () async {
    final store = LibraryStore.memory();
    store.publishers.add(Publisher(id: 99, name: 'Пустое', city: 'Казань', foundedYear: 2020));
    final repo = InMemoryPublisherRepository(store);
    await repo.hardDelete(99);
    expect(store.publishers.any((p) => p.id == 99), isFalse);
  });

  test('книга и читатель восстанавливаются из json', () {
    final store = LibraryStore.memory();
    final book = Book.fromJson(store.books.first.toJson());
    expect(book.title, store.books.first.title);
    expect(book.authorIds, store.books.first.authorIds);

    final reader = Reader.fromJson(store.readers.first.toJson());
    expect(reader.email, store.readers.first.email);
    expect(reader.card.number, store.readers.first.card.number);
  });

  test('старый json без новых полей не ломает загрузку', () {
    final genre = Genre.fromJson({'id': 1, 'name': 'Тест'});
    expect(genre.description, '');
    final publisher = Publisher.fromJson({'id': 2, 'name': 'Дом'});
    expect(publisher.city, '');
    expect(publisher.foundedYear, 1990);
  });

  test('валидаторы проверяют обязательность, email и ISBN', () {
    expect(V.required()(''), isNotNull);
    expect(V.required()('текст'), isNull);
    expect(V.email()('не почта'), isNotNull);
    expect(V.email()('user@mail.test'), isNull);
    expect(V.isbn()('123'), isNotNull);
    expect(V.isbn()('9785171183651'), isNull);
    expect(V.integer(min: 1450, max: 2100)('1200'), isNotNull);
    expect(V.integer(min: 1450, max: 2100)('2020'), isNull);
  });
}
