typedef Validator = String? Function(String?);

class V {
  static Validator required([String message = 'Поле обязательно']) {
    return (value) => (value == null || value.trim().isEmpty) ? message : null;
  }

  static Validator length({int min = 0, int max = 255}) {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      if (text.length < min) return 'Не короче $min символов';
      if (text.length > max) return 'Не длиннее $max символов';
      return null;
    };
  }

  static Validator integer({int? min, int? max}) {
    return (value) {
      final n = int.tryParse(value?.trim() ?? '');
      if (n == null) return 'Введите целое число';
      if (min != null && n < min) return 'Значение не меньше $min';
      if (max != null && n > max) return 'Значение не больше $max';
      return null;
    };
  }

  static Validator positive([String message = 'Значение должно быть неотрицательным']) {
    return (value) {
      final n = int.tryParse(value?.trim() ?? '');
      if (n == null) return 'Введите целое число';
      if (n < 0) return message;
      return null;
    };
  }

  static Validator email() {
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return 'Укажите адрес почты';
      return re.hasMatch(text) ? null : 'Некорректный адрес почты';
    };
  }

  static Validator isbn() {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      final digits = text.replaceAll(RegExp(r'[^0-9Xx]'), '');
      if (digits.length != 10 && digits.length != 13) {
        return 'ISBN должен содержать 10 или 13 цифр';
      }
      return null;
    };
  }

  static Validator date() {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      return DateTime.tryParse(text) == null ? 'Дата в формате ГГГГ-ММ-ДД' : null;
    };
  }

  static Validator all(List<Validator> items) {
    return (value) {
      for (final item in items) {
        final error = item(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
