import 'json_utils.dart';

class Loan {
  final int id;
  final int bookId;
  final String bookTitle;
  final int readerId;
  final String readerName;
  final DateTime issuedAt;
  final DateTime dueAt;
  final DateTime? returnedAt;
  final bool extended;

  const Loan({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.readerId,
    required this.readerName,
    required this.issuedAt,
    required this.dueAt,
    this.returnedAt,
    this.extended = false,
  });

  bool get isActive => returnedAt == null;

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: jsonInt(json['id']),
      bookId: jsonInt(json['bookId']),
      bookTitle: jsonString(json['bookTitle']),
      readerId: jsonInt(json['readerId']),
      readerName: jsonString(json['readerName']),
      issuedAt: jsonDate(json['issuedAt']) ?? DateTime.now(),
      dueAt: jsonDate(json['dueAt']) ?? DateTime.now(),
      returnedAt: jsonDate(json['returnedAt']),
      extended: jsonBool(json['extended']),
    );
  }
}
