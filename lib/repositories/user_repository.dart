import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/app_user.dart';
import '../models/role.dart';

class LibraryStats {
  final int books;
  final int authors;
  final int readers;
  final int activeLoans;
  final int users;

  const LibraryStats({
    required this.books,
    required this.authors,
    required this.readers,
    required this.activeLoans,
    required this.users,
  });

  factory LibraryStats.fromJson(Map<String, dynamic> json) {
    return LibraryStats(
      books: json['books'] as int? ?? 0,
      authors: json['authors'] as int? ?? 0,
      readers: json['readers'] as int? ?? 0,
      activeLoans: json['activeLoans'] as int? ?? 0,
      users: json['users'] as int? ?? 0,
    );
  }
}

class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  Future<List<AppUser>> find() => guard(() async {
        final response = await _dio.get<Map<String, dynamic>>('/users');
        final items = response.data?['items'] as List? ?? const [];
        return items.whereType<Map>().map((item) => AppUser.fromJson(Map<String, dynamic>.from(item))).toList();
      });

  Future<AppUser> updateRole(int id, Role role) => guard(() async {
        final response = await _dio.put<Map<String, dynamic>>(
          '/users/$id',
          data: {'role': role.id},
        );
        return AppUser.fromJson(response.data ?? const {});
      });

  Future<LibraryStats> stats() => guard(() async {
        final response = await _dio.get<Map<String, dynamic>>('/stats');
        return LibraryStats.fromJson(response.data ?? const {});
      });
}
