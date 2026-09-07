import 'json_utils.dart';

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'lastName': lastName,
    'firstName': firstName,
    'country': country,
    'birthYear': birthYear,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Author.fromJson(Map<String, dynamic> json) => Author(
    id: jsonInt(json['id']),
    lastName: jsonString(json['lastName']),
    firstName: jsonString(json['firstName']),
    country: jsonString(json['country']),
    birthYear: jsonInt(json['birthYear']),
    deletedAt: jsonDate(json['deletedAt']),
  );
}

class Genre {
  final int id;
  final String name;
  final String description;
  final DateTime? deletedAt;

  const Genre({
    required this.id,
    required this.name,
    this.description = '',
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Genre copyWith({
    String? name,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Genre(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
    id: jsonInt(json['id']),
    name: jsonString(json['name']),
    description: jsonString(json['description']),
    deletedAt: jsonDate(json['deletedAt']),
  );
}

class Publisher {
  final int id;
  final String name;
  final String city;
  final int foundedYear;
  final DateTime? deletedAt;

  const Publisher({
    required this.id,
    required this.name,
    this.city = '',
    this.foundedYear = 1990,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Publisher copyWith({
    String? name,
    String? city,
    int? foundedYear,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Publisher(
      id: id,
      name: name ?? this.name,
      city: city ?? this.city,
      foundedYear: foundedYear ?? this.foundedYear,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'foundedYear': foundedYear,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Publisher.fromJson(Map<String, dynamic> json) => Publisher(
    id: jsonInt(json['id']),
    name: jsonString(json['name']),
    city: jsonString(json['city']),
    foundedYear: jsonInt(json['foundedYear'], 1990),
    deletedAt: jsonDate(json['deletedAt']),
  );
}
