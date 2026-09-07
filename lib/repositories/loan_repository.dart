import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/loan.dart';
import '../models/page_result.dart';

class LoanRepository {
  final Dio _dio;

  LoanRepository(this._dio);

  Future<PageResult<Loan>> mine() => guard(() async {
        final response = await _dio.get<Map<String, dynamic>>('/loans/mine');
        return _page(response.data ?? const {});
      });

  Future<PageResult<Loan>> find({int page = 1, int size = 20}) => guard(() async {
        final response = await _dio.get<Map<String, dynamic>>(
          '/loans',
          queryParameters: {'page': page, 'size': size},
        );
        return _page(response.data ?? const {});
      });

  Future<Loan> issue({required int bookId, required int readerId}) => guard(() async {
        final response = await _dio.post<Map<String, dynamic>>(
          '/loans',
          data: {'bookId': bookId, 'readerId': readerId},
        );
        return Loan.fromJson(response.data ?? const {});
      });

  Future<Loan> extend(int id) => guard(() async {
        final response = await _dio.post<Map<String, dynamic>>('/loans/$id/extend');
        return Loan.fromJson(response.data ?? const {});
      });

  Future<Loan> close(int id) => guard(() async {
        final response = await _dio.post<Map<String, dynamic>>('/loans/$id/return');
        return Loan.fromJson(response.data ?? const {});
      });

  PageResult<Loan> _page(Map<String, dynamic> data) {
    return PageResult(
      items: (data['items'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => Loan.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      page: data['page'] as int? ?? 1,
      size: data['size'] as int? ?? 10,
      total: data['total'] as int? ?? 0,
    );
  }
}
