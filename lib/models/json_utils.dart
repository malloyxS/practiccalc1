int jsonInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  if (value is Map) return jsonInt(value['id'], fallback);
  return fallback;
}

String jsonString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

bool jsonBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is String) return value == 'true' || value == '1';
  return fallback;
}

List<int> jsonIntList(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => jsonInt(item)).toList();
}

DateTime? jsonDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
