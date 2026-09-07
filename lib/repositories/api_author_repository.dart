import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_exceptions.dart';
import '../models/author.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import 'author_repository.dart';

class ApiAuthorRepository implements AuthorRepository {
  final Dio _dio;
  CancelToken? _findToken;

  ApiAuthorRepository(this._dio);

  @override
  Future<PageResult<Author>> find(AuthorQuery q) => guard(() async {
        _findToken?.cancel('устаревший поиск');
        _findToken = CancelToken();
        return withRetry(() async {
          final response = await _dio.get<Map<String, dynamic>>(
            '/authors',
            cancelToken: _findToken,
            queryParameters: {
              if (q.search.trim().isNotEmpty) 'search': q.search.trim(),
              if (q.country != null) 'country': q.country,
              'sort': '${q.sortField},${q.sortAscending ? 'asc' : 'desc'}',
              'page': q.page,
              'size': q.size,
              if (q.includeDeleted) 'includeDeleted': true,
              if (q.fail) '__fail': 500,
            },
          );
          final data = response.data ?? const {};
          return PageResult(
            items: (data['items'] as List? ?? const [])
                .whereType<Map>()
                .map((item) => Author.fromJson(Map<String, dynamic>.from(item)))
                .toList(),
            page: data['page'] as int? ?? 1,
            size: data['size'] as int? ?? q.size,
            total: data['total'] as int? ?? 0,
          );
        });
      });

  @override
  Future<Author?> findById(int id) => guard(() async {
        final response = await _dio.get<Map<String, dynamic>>('/authors/$id');
        final data = response.data;
        return data == null ? null : Author.fromJson(data);
      });

  @override
  Future<Author> create(Author author) => guard(() async {
        final response = await _dio.post<Map<String, dynamic>>('/authors', data: author.toJson());
        return Author.fromJson(response.data ?? const {});
      });

  @override
  Future<Author> update(Author author) => guard(() async {
        final response = await _dio.put<Map<String, dynamic>>('/authors/${author.id}', data: author.toJson());
        return Author.fromJson(response.data ?? const {});
      });

  @override
  Future<void> softDelete(int id) => guard(() => _dio.delete('/authors/$id'));

  @override
  Future<void> hardDelete(int id) =>
      guard(() => _dio.delete('/authors/$id', queryParameters: {'hard': true}));

  @override
  Future<void> restore(int id) => guard(() => _dio.post('/authors/$id/restore'));

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
        final response = await _dio.post<Map<String, dynamic>>('/authors/bulk-delete', data: {'ids': ids});
        return (response.data?['deleted'] as int?) ?? 0;
      });
}
