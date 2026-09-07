import 'json_utils.dart';

class LibraryCard {
  final String number;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final bool active;

  const LibraryCard({
    required this.number,
    required this.issuedAt,
    required this.expiresAt,
    this.active = true,
  });

  LibraryCard copyWith({
    String? number,
    DateTime? issuedAt,
    DateTime? expiresAt,
    bool? active,
  }) {
    return LibraryCard(
      number: number ?? this.number,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'issuedAt': issuedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'active': active,
  };

  factory LibraryCard.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    return LibraryCard(
      number: jsonString(data['number']),
      issuedAt: jsonDate(data['issuedAt']) ?? DateTime(2024, 1, 1),
      expiresAt: jsonDate(data['expiresAt']) ?? DateTime(2027, 1, 1),
      active: jsonBool(data['active'], true),
    );
  }
}

class Reader {
  final int id;
  final String lastName;
  final String firstName;
  final String email;
  final String phone;
  final LibraryCard card;
  final DateTime? deletedAt;

  const Reader({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.email,
    required this.phone,
    required this.card,
    this.deletedAt,
  });

  String get fullName => '$lastName $firstName';

  bool get isDeleted => deletedAt != null;

  Reader copyWith({
    String? lastName,
    String? firstName,
    String? email,
    String? phone,
    LibraryCard? card,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Reader(
      id: id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      card: card ?? this.card,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lastName': lastName,
    'firstName': firstName,
    'email': email,
    'phone': phone,
    'card': card.toJson(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Reader.fromJson(Map<String, dynamic> json) => Reader(
    id: jsonInt(json['id']),
    lastName: jsonString(json['lastName']),
    firstName: jsonString(json['firstName']),
    email: jsonString(json['email']),
    phone: jsonString(json['phone']),
    card: LibraryCard.fromJson(
      json['card'] is Map<String, dynamic>
          ? json['card'] as Map<String, dynamic>
          : null,
    ),
    deletedAt: jsonDate(json['deletedAt']),
  );
}
