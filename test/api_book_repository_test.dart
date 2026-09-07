import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calc_web/core/api_client.dart';
import 'package:calc_web/core/api_exceptions.dart';
import 'package:calc_web/models/book.dart';
import 'package:calc_web/models/book_query.dart';
import 'package:calc_web/repositories/api_book_repository.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.onFetch);

  final Future<ResponseBody> Function(RequestOptions options) onFetch;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return onFetch(options);
  }
}

ResponseBody jsonBody(int status, Object data) {
  return ResponseBody.fromString(
    jsonEncode(data),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Dio mockDio(Future<ResponseBody> Function(RequestOptions) handler) {
  final dio = buildDio();
  dio.httpClientAdapter = _Adapter(handler);
  return dio;
}

const _sampleBook = {
  'id': 1,
  'title': 'Война и мир',
  'isbn': '978-5-17-118365-1',
  'year': 1869,
  'pages': 1274,
  'publisherId': 1,
  'authorIds': [1],
  'genreIds': [1, 3],
  'copiesTotal': 8,
  'copiesAvailable': 3,
};

Book _draft({String isbn = '978-0-00-000000-0'}) => Book(
  id: 0,
  title: 'Тест',
  isbn: isbn,
  year: 2020,
  pages: 100,
  publisherId: 1,
  authorIds: const [1],
  genreIds: const [1],
  copiesTotal: 1,
  copiesAvailable: 1,
);

void main() {
  test('find разбирает страницу с сервера', () async {
    final repo = ApiBookRepository(
      mockDio((options) async {
        expect(options.method, 'GET');
        expect(options.path, '/books');
        expect(options.queryParameters['search'], 'война');
        expect(options.queryParameters['page'], 2);
        return jsonBody(200, {
          'items': [_sampleBook],
          'page': 2,
          'size': 10,
          'total': 24,
        });
      }),
    );

    final page = await repo.find(const BookQuery(search: 'война', page: 2));
    expect(page.page, 2);
    expect(page.total, 24);
    expect(page.items, hasLength(1));
    expect(page.items.single.title, 'Война и мир');
    expect(page.items.single.genreIds, [1, 3]);
  });

  test('create с занятым ISBN даёт ValidationException', () async {
    final repo = ApiBookRepository(
      mockDio((options) async {
        expect(options.method, 'POST');
        return jsonBody(422, {
          'message': 'Ошибка валидации',
          'errors': {'isbn': 'ISBN уже используется'},
        });
      }),
    );

    expect(
      () => repo.create(_draft(isbn: '978-5-17-118365-1')),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.errors['isbn'],
          'isbn',
          'ISBN уже используется',
        ),
      ),
    );
  });

  test('недоступный сервер даёт NetworkException', () async {
    final repo = ApiBookRepository(
      mockDio((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }),
    );

    expect(
      () => repo.find(const BookQuery()),
      throwsA(isA<NetworkException>()),
    );
  });

  test('выдача без экземпляров даёт ConflictException', () async {
    final repo = ApiBookRepository(
      mockDio((options) async {
        expect(options.path, '/books/11/issue');
        return jsonBody(409, {'message': 'Нет свободных экземпляров'});
      }),
    );

    expect(
      () => repo.issue(11),
      throwsA(
        isA<ConflictException>().having(
          (e) => e.message,
          'message',
          'Нет свободных экземпляров',
        ),
      ),
    );
  });

  test('чтение повторяется до трёх раз при сбое сети', () async {
    var calls = 0;
    final repo = ApiBookRepository(
      mockDio((options) async {
        calls += 1;
        if (calls < 3) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        }
        return jsonBody(200, {
          'items': [_sampleBook],
          'page': 1,
          'size': 10,
          'total': 1,
        });
      }),
    );

    final page = await repo.find(const BookQuery());
    expect(calls, 3);
    expect(page.items.single.id, 1);
  });

  test('повторный поиск отменяет предыдущий запрос', () async {
    var calls = 0;
    final repo = ApiBookRepository(
      mockDio((options) async {
        calls += 1;
        if (calls == 1) {
          await Future<void>.delayed(const Duration(milliseconds: 80));
        }
        return jsonBody(200, {
          'items': [_sampleBook],
          'page': 1,
          'size': 10,
          'total': 1,
        });
      }),
    );

    final first = repo.find(const BookQuery(search: 'а'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final second = repo.find(const BookQuery(search: 'аб'));
    await expectLater(first, throwsA(isA<RequestCancelledException>()));
    expect((await second).total, 1);
  });
}
