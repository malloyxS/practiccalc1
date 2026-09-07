import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_exceptions.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import 'book_repository.dart';

class ApiBookRepository implements BookRepository {
  final Dio _dio;
  CancelToken? _findToken;

  ApiBookRepository(this._dio);

  Map<String, dynamic> _debugParams(BookQuery q) => {
        if (q.fail) '__fail': 500,
        if (q.delayMs != null) '__delay': q.delayMs,
      };

  @override
  Future<PageResult<Book>> find(BookQuery q) => guard(() async {
        _findToken?.cancel('устаревший поиск');
        _findToken = CancelToken();
        return withRetry(() async {
          final response = await _dio.get<Map<String, dynamic>>(
            '/books',
            cancelToken: _findToken,
            queryParameters: {
              if (q.search.trim().isNotEmpty) 'search': q.search.trim(),
              if (q.genreId != null) 'genreId': q.genreId,
              if (q.publisherId != null) 'publisherId': q.publisherId,
              if (q.yearFrom != null) 'yearFrom': q.yearFrom,
              if (q.yearTo != null) 'yearTo': q.yearTo,
              'sort': '${q.sortField},${q.sortAscending ? 'asc' : 'desc'}',
              'page': q.page,
              'size': q.size,
              if (q.includeDeleted) 'includeDeleted': true,
              ..._debugParams(q),
            },
          );
          final data = response.data ?? const {};
          return PageResult(
            items: (data['items'] as List? ?? const [])
                .whereType<Map>()
                .map((item) => Book.fromJson(Map<String, dynamic>.from(item)))
                .toList(),
            page: data['page'] as int? ?? 1,
            size: data['size'] as int? ?? q.size,
            total: data['total'] as int? ?? 0,
          );
        });
      });

  @override
  Future<Book?> findById(int id) => guard(() async {
        return withRetry(() async {
          final response = await _dio.get<Map<String, dynamic>>('/books/$id');
          final data = response.data;
          if (data == null) return null;
          return Book.fromJson(data);
        });
      });

  @override
  Future<Book> create(Book book) => guard(() async {
        final response = await _dio.post<Map<String, dynamic>>('/books', data: _body(book));
        return Book.fromJson(response.data ?? const {});
      });

  @override
  Future<Book> update(Book book) => guard(() async {
        final response = await _dio.put<Map<String, dynamic>>('/books/${book.id}', data: _body(book));
        return Book.fromJson(response.data ?? const {});
      });

  @override
  Future<void> softDelete(int id) => guard(() => _dio.delete('/books/$id'));

  @override
  Future<void> hardDelete(int id) =>
      guard(() => _dio.delete('/books/$id', queryParameters: {'hard': true}));

  @override
  Future<void> restore(int id) => guard(() => _dio.post('/books/$id/restore'));

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
        final response = await _dio.post<Map<String, dynamic>>('/books/bulk-delete', data: {'ids': ids});
        return (response.data?['deleted'] as int?) ?? 0;
      });

  @override
  Future<Book> issue(int id) => guard(() async {
        final response = await _dio.post<Map<String, dynamic>>('/books/$id/issue');
        return Book.fromJson(response.data ?? const {});
      });

  Map<String, dynamic> _body(Book book) => {
        'title': book.title,
        'isbn': book.isbn,
        'year': book.year,
        'pages': book.pages,
        'publisherId': book.publisherId,
        'authorIds': book.authorIds,
        'genreIds': book.genreIds,
        'copiesTotal': book.copiesTotal,
        'copiesAvailable': book.copiesAvailable,
      };
}
