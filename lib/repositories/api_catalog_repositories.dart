import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_exceptions.dart';
import '../models/author.dart';
import '../models/book_query.dart';
import '../models/page_result.dart';
import '../models/reader.dart';
import 'catalog_repositories.dart';

PageResult<T> _page<T>(
  Map<String, dynamic> data,
  T Function(Map<String, dynamic>) fromJson,
  int size,
) {
  return PageResult(
    items: (data['items'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    page: data['page'] as int? ?? 1,
    size: data['size'] as int? ?? size,
    total: data['total'] as int? ?? 0,
  );
}

class ApiGenreRepository implements GenreRepository {
  final Dio _dio;
  CancelToken? _findToken;

  ApiGenreRepository(this._dio);

  @override
  Future<PageResult<Genre>> find(CatalogQuery q) => guard(() async {
    _findToken?.cancel('устаревший поиск');
    _findToken = CancelToken();
    return withRetry(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/genres',
        cancelToken: _findToken,
        queryParameters: {
          if (q.search.trim().isNotEmpty) 'search': q.search.trim(),
          'sort': '${q.sortField},${q.sortAscending ? 'asc' : 'desc'}',
          'page': q.page,
          'size': q.size,
          if (q.includeDeleted) 'includeDeleted': true,
          if (q.fail) '__fail': 500,
        },
      );
      return _page(response.data ?? const {}, Genre.fromJson, q.size);
    });
  });

  @override
  Future<Genre?> findById(int id) => guard(() async {
    final response = await _dio.get<Map<String, dynamic>>('/genres/$id');
    return response.data == null ? null : Genre.fromJson(response.data!);
  });

  @override
  Future<Genre> create(Genre genre) => guard(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/genres',
      data: genre.toJson(),
    );
    return Genre.fromJson(response.data ?? const {});
  });

  @override
  Future<Genre> update(Genre genre) => guard(() async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/genres/${genre.id}',
      data: genre.toJson(),
    );
    return Genre.fromJson(response.data ?? const {});
  });

  @override
  Future<void> softDelete(int id) => guard(() => _dio.delete('/genres/$id'));

  @override
  Future<void> hardDelete(int id) =>
      guard(() => _dio.delete('/genres/$id', queryParameters: {'hard': true}));

  @override
  Future<void> restore(int id) => guard(() => _dio.post('/genres/$id/restore'));

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/genres/bulk-delete',
      data: {'ids': ids},
    );
    return (response.data?['deleted'] as int?) ?? 0;
  });
}

class ApiPublisherRepository implements PublisherRepository {
  final Dio _dio;
  CancelToken? _findToken;

  ApiPublisherRepository(this._dio);

  @override
  Future<PageResult<Publisher>> find(CatalogQuery q) => guard(() async {
    _findToken?.cancel('устаревший поиск');
    _findToken = CancelToken();
    return withRetry(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/publishers',
        cancelToken: _findToken,
        queryParameters: {
          if (q.search.trim().isNotEmpty) 'search': q.search.trim(),
          'sort': '${q.sortField},${q.sortAscending ? 'asc' : 'desc'}',
          'page': q.page,
          'size': q.size,
          if (q.includeDeleted) 'includeDeleted': true,
          if (q.fail) '__fail': 500,
        },
      );
      return _page(response.data ?? const {}, Publisher.fromJson, q.size);
    });
  });

  @override
  Future<Publisher?> findById(int id) => guard(() async {
    final response = await _dio.get<Map<String, dynamic>>('/publishers/$id');
    return response.data == null ? null : Publisher.fromJson(response.data!);
  });

  @override
  Future<Publisher> create(Publisher publisher) => guard(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/publishers',
      data: publisher.toJson(),
    );
    return Publisher.fromJson(response.data ?? const {});
  });

  @override
  Future<Publisher> update(Publisher publisher) => guard(() async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/publishers/${publisher.id}',
      data: publisher.toJson(),
    );
    return Publisher.fromJson(response.data ?? const {});
  });

  @override
  Future<void> softDelete(int id) =>
      guard(() => _dio.delete('/publishers/$id'));

  @override
  Future<void> hardDelete(int id) => guard(
    () => _dio.delete('/publishers/$id', queryParameters: {'hard': true}),
  );

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post('/publishers/$id/restore'));

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/publishers/bulk-delete',
      data: {'ids': ids},
    );
    return (response.data?['deleted'] as int?) ?? 0;
  });
}

class ApiReaderRepository implements ReaderRepository {
  final Dio _dio;
  CancelToken? _findToken;

  ApiReaderRepository(this._dio);

  @override
  Future<PageResult<Reader>> find(CatalogQuery q) => guard(() async {
    _findToken?.cancel('устаревший поиск');
    _findToken = CancelToken();
    return withRetry(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/readers',
        cancelToken: _findToken,
        queryParameters: {
          if (q.search.trim().isNotEmpty) 'search': q.search.trim(),
          'sort': '${q.sortField},${q.sortAscending ? 'asc' : 'desc'}',
          'page': q.page,
          'size': q.size,
          if (q.includeDeleted) 'includeDeleted': true,
          if (q.fail) '__fail': 500,
        },
      );
      return _page(response.data ?? const {}, Reader.fromJson, q.size);
    });
  });

  @override
  Future<Reader?> findById(int id) => guard(() async {
    final response = await _dio.get<Map<String, dynamic>>('/readers/$id');
    return response.data == null ? null : Reader.fromJson(response.data!);
  });

  @override
  Future<Reader> create(Reader reader) => guard(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/readers',
      data: reader.toJson(),
    );
    return Reader.fromJson(response.data ?? const {});
  });

  @override
  Future<Reader> update(Reader reader) => guard(() async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/readers/${reader.id}',
      data: reader.toJson(),
    );
    return Reader.fromJson(response.data ?? const {});
  });

  @override
  Future<void> softDelete(int id) => guard(() => _dio.delete('/readers/$id'));

  @override
  Future<void> hardDelete(int id) =>
      guard(() => _dio.delete('/readers/$id', queryParameters: {'hard': true}));

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post('/readers/$id/restore'));

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/readers/bulk-delete',
      data: {'ids': ids},
    );
    return (response.data?['deleted'] as int?) ?? 0;
  });
}
