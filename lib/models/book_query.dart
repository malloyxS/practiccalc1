class BookQuery {
  final String search;
  final int? genreId;
  final int? publisherId;
  final int? yearFrom;
  final int? yearTo;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;
  final bool fail;

  const BookQuery({
    this.search = '',
    this.genreId,
    this.publisherId,
    this.yearFrom,
    this.yearTo,
    this.sortField = 'title',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
    this.fail = false,
  });

  factory BookQuery.fromUri(Uri uri) {
    final q = uri.queryParameters;
    final sort = q['sort'] ?? 'title,asc';
    final parts = sort.split(',');
    return BookQuery(
      search: q['search'] ?? '',
      genreId: int.tryParse(q['genreId'] ?? ''),
      publisherId: int.tryParse(q['publisherId'] ?? ''),
      yearFrom: int.tryParse(q['yearFrom'] ?? ''),
      yearTo: int.tryParse(q['yearTo'] ?? ''),
      sortField: parts.isEmpty || parts.first.isEmpty ? 'title' : parts.first,
      sortAscending: parts.length < 2 || parts[1] != 'desc',
      page: int.tryParse(q['page'] ?? '') ?? 1,
      size: int.tryParse(q['size'] ?? '') ?? 10,
      includeDeleted: q['includeDeleted'] == '1' || q['includeDeleted'] == 'true',
      fail: q['fail'] == '1',
    );
  }

  String toLocation([String path = '/books']) {
    final params = <String, String>{};
    if (search.isNotEmpty) params['search'] = search;
    if (genreId != null) params['genreId'] = '$genreId';
    if (publisherId != null) params['publisherId'] = '$publisherId';
    if (yearFrom != null) params['yearFrom'] = '$yearFrom';
    if (yearTo != null) params['yearTo'] = '$yearTo';
    if (sortField != 'title' || !sortAscending) {
      params['sort'] = '$sortField,${sortAscending ? 'asc' : 'desc'}';
    }
    if (page != 1) params['page'] = '$page';
    if (size != 10) params['size'] = '$size';
    if (includeDeleted) params['includeDeleted'] = '1';
    if (fail) params['fail'] = '1';
    return Uri(path: path, queryParameters: params.isEmpty ? null : params).toString();
  }

  BookQuery copyWith({
    String? search,
    Object? genreId = _unset,
    Object? publisherId = _unset,
    Object? yearFrom = _unset,
    Object? yearTo = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
    bool? fail,
  }) {
    return BookQuery(
      search: search ?? this.search,
      genreId: genreId == _unset ? this.genreId : genreId as int?,
      publisherId: publisherId == _unset ? this.publisherId : publisherId as int?,
      yearFrom: yearFrom == _unset ? this.yearFrom : yearFrom as int?,
      yearTo: yearTo == _unset ? this.yearTo : yearTo as int?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
      fail: fail ?? this.fail,
    );
  }

  static const _unset = Object();

  @override
  bool operator ==(Object other) {
    return other is BookQuery &&
        other.search == search &&
        other.genreId == genreId &&
        other.publisherId == publisherId &&
        other.yearFrom == yearFrom &&
        other.yearTo == yearTo &&
        other.sortField == sortField &&
        other.sortAscending == sortAscending &&
        other.page == page &&
        other.size == size &&
        other.includeDeleted == includeDeleted &&
        other.fail == fail;
  }

  @override
  int get hashCode => Object.hash(
        search,
        genreId,
        publisherId,
        yearFrom,
        yearTo,
        sortField,
        sortAscending,
        page,
        size,
        includeDeleted,
        fail,
      );
}

class AuthorQuery {
  final String search;
  final String? country;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;
  final bool fail;

  const AuthorQuery({
    this.search = '',
    this.country,
    this.sortField = 'lastName',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
    this.fail = false,
  });

  factory AuthorQuery.fromUri(Uri uri) {
    final q = uri.queryParameters;
    final sort = q['sort'] ?? 'lastName,asc';
    final parts = sort.split(',');
    return AuthorQuery(
      search: q['search'] ?? '',
      country: (q['country'] ?? '').isEmpty ? null : q['country'],
      sortField: parts.isEmpty || parts.first.isEmpty ? 'lastName' : parts.first,
      sortAscending: parts.length < 2 || parts[1] != 'desc',
      page: int.tryParse(q['page'] ?? '') ?? 1,
      size: int.tryParse(q['size'] ?? '') ?? 10,
      includeDeleted: q['includeDeleted'] == '1' || q['includeDeleted'] == 'true',
      fail: q['fail'] == '1',
    );
  }

  String toLocation([String path = '/authors']) {
    final params = <String, String>{};
    if (search.isNotEmpty) params['search'] = search;
    if (country != null) params['country'] = country!;
    if (sortField != 'lastName' || !sortAscending) {
      params['sort'] = '$sortField,${sortAscending ? 'asc' : 'desc'}';
    }
    if (page != 1) params['page'] = '$page';
    if (size != 10) params['size'] = '$size';
    if (includeDeleted) params['includeDeleted'] = '1';
    if (fail) params['fail'] = '1';
    return Uri(path: path, queryParameters: params.isEmpty ? null : params).toString();
  }

  AuthorQuery copyWith({
    String? search,
    Object? country = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
    bool? fail,
  }) {
    return AuthorQuery(
      search: search ?? this.search,
      country: country == _unset ? this.country : country as String?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
      fail: fail ?? this.fail,
    );
  }

  static const _unset = Object();

  @override
  bool operator ==(Object other) {
    return other is AuthorQuery &&
        other.search == search &&
        other.country == country &&
        other.sortField == sortField &&
        other.sortAscending == sortAscending &&
        other.page == page &&
        other.size == size &&
        other.includeDeleted == includeDeleted &&
        other.fail == fail;
  }

  @override
  int get hashCode => Object.hash(
        search,
        country,
        sortField,
        sortAscending,
        page,
        size,
        includeDeleted,
        fail,
      );
}
