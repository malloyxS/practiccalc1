import '../models/author.dart';
import '../models/book.dart';
import '../models/reader.dart';

const genres = [
  Genre(id: 1, name: 'Художественная'),
  Genre(id: 2, name: 'Фантастика'),
  Genre(id: 3, name: 'История'),
  Genre(id: 4, name: 'Финансы'),
  Genre(id: 5, name: 'Программирование'),
];

const publishers = [
  Publisher(id: 1, name: 'АСТ', city: 'Москва', foundedYear: 1990),
  Publisher(id: 2, name: 'Эксмо', city: 'Москва', foundedYear: 1991),
  Publisher(id: 3, name: 'Питер', city: 'Санкт-Петербург', foundedYear: 1991),
  Publisher(id: 4, name: 'Капитал Пресс', city: 'Москва', foundedYear: 2005),
  Publisher(id: 5, name: 'МИФ', city: 'Москва', foundedYear: 2005),
];

const seedAuthors = [
  Author(id: 1, lastName: 'Толстой', firstName: 'Лев', country: 'Россия', birthYear: 1828),
  Author(id: 2, lastName: 'Достоевский', firstName: 'Фёдор', country: 'Россия', birthYear: 1821),
  Author(id: 3, lastName: 'Булгаков', firstName: 'Михаил', country: 'Россия', birthYear: 1891),
  Author(id: 4, lastName: 'Оруэлл', firstName: 'Джордж', country: 'Великобритания', birthYear: 1903),
  Author(id: 5, lastName: 'Брэдбери', firstName: 'Рэй', country: 'США', birthYear: 1920),
  Author(id: 6, lastName: 'Кинг', firstName: 'Стивен', country: 'США', birthYear: 1947),
  Author(id: 7, lastName: 'Мартин', firstName: 'Роберт', country: 'США', birthYear: 1952),
  Author(id: 8, lastName: 'Фаулер', firstName: 'Мартин', country: 'Великобритания', birthYear: 1963),
  Author(id: 9, lastName: 'Глуховский', firstName: 'Дмитрий', country: 'Россия', birthYear: 1979),
  Author(id: 10, lastName: 'Пелевин', firstName: 'Виктор', country: 'Россия', birthYear: 1962),
];

const seedBooks = [
  Book(id: 1, title: 'Война и мир', isbn: '978-5-17-118365-1', year: 1869, pages: 1274, publisherId: 1, authorIds: [1], genreIds: [1, 3], copiesTotal: 8, copiesAvailable: 3),
  Book(id: 2, title: 'Анна Каренина', isbn: '978-5-17-090331-3', year: 1877, pages: 864, publisherId: 1, authorIds: [1], genreIds: [1], copiesTotal: 5, copiesAvailable: 2),
  Book(id: 3, title: 'Преступление и наказание', isbn: '978-5-17-082589-3', year: 1866, pages: 608, publisherId: 2, authorIds: [2], genreIds: [1], copiesTotal: 6, copiesAvailable: 1),
  Book(id: 4, title: 'Идиот', isbn: '978-5-17-098211-0', year: 1869, pages: 640, publisherId: 2, authorIds: [2], genreIds: [1], copiesTotal: 4, copiesAvailable: 4),
  Book(id: 5, title: 'Мастер и Маргарита', isbn: '978-5-17-087892-8', year: 1967, pages: 480, publisherId: 1, authorIds: [3], genreIds: [1, 2], copiesTotal: 10, copiesAvailable: 4),
  Book(id: 6, title: 'Собачье сердце', isbn: '978-5-17-112004-5', year: 1925, pages: 160, publisherId: 1, authorIds: [3], genreIds: [1, 2], copiesTotal: 7, copiesAvailable: 5),
  Book(id: 7, title: '1984', isbn: '978-5-17-080115-6', year: 1949, pages: 320, publisherId: 2, authorIds: [4], genreIds: [2], copiesTotal: 9, copiesAvailable: 2),
  Book(id: 8, title: 'Скотный двор', isbn: '978-5-17-090990-2', year: 1945, pages: 112, publisherId: 2, authorIds: [4], genreIds: [1, 2], copiesTotal: 5, copiesAvailable: 5),
  Book(id: 9, title: '451 градус по Фаренгейту', isbn: '978-5-17-083001-9', year: 1953, pages: 256, publisherId: 2, authorIds: [5], genreIds: [2], copiesTotal: 6, copiesAvailable: 3),
  Book(id: 10, title: 'Вино из одуванчиков', isbn: '978-5-17-104332-2', year: 1957, pages: 320, publisherId: 1, authorIds: [5], genreIds: [1], copiesTotal: 4, copiesAvailable: 1),
  Book(id: 11, title: 'Сияние', isbn: '978-5-17-086541-6', year: 1977, pages: 544, publisherId: 2, authorIds: [6], genreIds: [1], copiesTotal: 5, copiesAvailable: 0),
  Book(id: 12, title: 'Оно', isbn: '978-5-17-102118-4', year: 1986, pages: 1116, publisherId: 2, authorIds: [6], genreIds: [1], copiesTotal: 3, copiesAvailable: 1),
  Book(id: 13, title: 'Чистый код', isbn: '978-5-4461-0960-9', year: 2008, pages: 464, publisherId: 3, authorIds: [7], genreIds: [5], copiesTotal: 8, copiesAvailable: 6),
  Book(id: 14, title: 'Идеальный программист', isbn: '978-5-459-01044-2', year: 2011, pages: 224, publisherId: 3, authorIds: [7], genreIds: [5], copiesTotal: 5, copiesAvailable: 4),
  Book(id: 15, title: 'Рефакторинг', isbn: '978-5-4461-0772-8', year: 2019, pages: 448, publisherId: 3, authorIds: [8], genreIds: [5], copiesTotal: 6, copiesAvailable: 3),
  Book(id: 16, title: 'Шаблоны корпоративных приложений', isbn: '978-5-4461-0994-4', year: 2002, pages: 544, publisherId: 3, authorIds: [8], genreIds: [5], copiesTotal: 4, copiesAvailable: 2),
  Book(id: 17, title: 'Метро 2033', isbn: '978-5-17-056106-1', year: 2005, pages: 384, publisherId: 1, authorIds: [9], genreIds: [2], copiesTotal: 7, copiesAvailable: 2),
  Book(id: 18, title: 'Текст', isbn: '978-5-17-112441-8', year: 2017, pages: 320, publisherId: 1, authorIds: [9], genreIds: [1], copiesTotal: 5, copiesAvailable: 5),
  Book(id: 19, title: 'Generation «П»', isbn: '978-5-17-080234-4', year: 1999, pages: 336, publisherId: 2, authorIds: [10], genreIds: [1], copiesTotal: 6, copiesAvailable: 3),
  Book(id: 20, title: 'Чапаев и Пустота', isbn: '978-5-17-098765-8', year: 1996, pages: 400, publisherId: 2, authorIds: [10], genreIds: [1, 2], copiesTotal: 4, copiesAvailable: 1),
  Book(id: 21, title: 'Деньги как инструмент', isbn: '978-5-9614-1234-7', year: 2018, pages: 288, publisherId: 4, authorIds: [8], genreIds: [4], copiesTotal: 5, copiesAvailable: 4),
  Book(id: 22, title: 'Личные финансы', isbn: '978-5-9614-2222-1', year: 2021, pages: 256, publisherId: 4, authorIds: [7], genreIds: [4], copiesTotal: 6, copiesAvailable: 6),
  Book(id: 23, title: 'Капитал для начинающих', isbn: '978-5-00146-333-0', year: 2020, pages: 312, publisherId: 5, authorIds: [8], genreIds: [4], copiesTotal: 4, copiesAvailable: 2),
  Book(id: 24, title: 'История денег', isbn: '978-5-17-134001-2', year: 2014, pages: 400, publisherId: 5, authorIds: [1], genreIds: [3, 4], copiesTotal: 3, copiesAvailable: 3),
];

final seedReaders = [
  Reader(id: 1, lastName: 'Иванов', firstName: 'Пётр', email: 'ivanov@mail.test', phone: '+7 900 111-22-33', card: LibraryCard(number: 'LC-1001', issuedAt: DateTime(2024, 1, 10), expiresAt: DateTime(2027, 1, 10))),
  Reader(id: 2, lastName: 'Петрова', firstName: 'Анна', email: 'petrova@mail.test', phone: '+7 900 222-33-44', card: LibraryCard(number: 'LC-1002', issuedAt: DateTime(2024, 3, 2), expiresAt: DateTime(2026, 3, 2))),
  Reader(id: 3, lastName: 'Сидоров', firstName: 'Илья', email: 'sidorov@mail.test', phone: '+7 900 333-44-55', card: LibraryCard(number: 'LC-1003', issuedAt: DateTime(2023, 9, 1), expiresAt: DateTime(2026, 9, 1))),
  Reader(id: 4, lastName: 'Кузнецова', firstName: 'Мария', email: 'kuznetsova@mail.test', phone: '+7 900 444-55-66', card: LibraryCard(number: 'LC-1004', issuedAt: DateTime(2025, 2, 14), expiresAt: DateTime(2028, 2, 14))),
  Reader(id: 5, lastName: 'Орлов', firstName: 'Никита', email: 'orlov@mail.test', phone: '+7 900 555-66-77', card: LibraryCard(number: 'LC-1005', issuedAt: DateTime(2024, 6, 20), expiresAt: DateTime(2027, 6, 20), active: false)),
  Reader(id: 6, lastName: 'Морозова', firstName: 'Елена', email: 'morozova@mail.test', phone: '+7 900 666-77-88', card: LibraryCard(number: 'LC-1006', issuedAt: DateTime(2022, 11, 5), expiresAt: DateTime(2025, 11, 5))),
  Reader(id: 7, lastName: 'Волков', firstName: 'Артём', email: 'volkov@mail.test', phone: '+7 900 777-88-99', card: LibraryCard(number: 'LC-1007', issuedAt: DateTime(2025, 1, 8), expiresAt: DateTime(2028, 1, 8))),
  Reader(id: 8, lastName: 'Соколова', firstName: 'Дарья', email: 'sokolova@mail.test', phone: '+7 900 888-99-00', card: LibraryCard(number: 'LC-1008', issuedAt: DateTime(2024, 8, 19), expiresAt: DateTime(2027, 8, 19))),
];

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
  for (final item in seedAuthors) {
    if (item.id == id) return item;
  }
  return null;
}

String genreNames(List<int> ids) =>
    ids.map((id) => genreById(id)?.name ?? '$id').join(', ');

String publisherName(int id) => publisherById(id)?.name ?? '$id';

String authorNames(List<int> ids) =>
    ids.map((id) => authorById(id)?.fullName ?? '$id').join(', ');
