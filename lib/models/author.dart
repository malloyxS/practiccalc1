class Author {
  final int id;
  final String lastName;
  final String firstName;
  final String country;
  final int birthYear;
  final DateTime? deletedAt;

  const Author({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.country,
    required this.birthYear,
    this.deletedAt,
  });

  String get fullName => '$lastName $firstName';

  bool get isDeleted => deletedAt != null;

  Author copyWith({
    String? lastName,
    String? firstName,
    String? country,
    int? birthYear,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Author(
      id: id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      country: country ?? this.country,
      birthYear: birthYear ?? this.birthYear,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}

class Genre {
  final int id;
  final String name;

  const Genre({required this.id, required this.name});
}

class Publisher {
  final int id;
  final String name;

  const Publisher({required this.id, required this.name});
}
