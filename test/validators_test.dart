import 'package:calc_web/core/validators.dart';
import 'package:calc_web/models/book.dart';
import 'package:calc_web/models/app_user.dart';
import 'package:calc_web/models/role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Валидатор обязательного поля', () {
    test('пустая строка отклоняется', () {
      expect(V.required()(''), isNotNull);
      expect(V.required()('   '), isNotNull);
    });

    test('непустая строка принимается', () {
      expect(V.required()('Война и мир'), isNull);
    });
  });

  group('Длина и число', () {
    test('длина отклоняет короткую строку', () {
      expect(V.length(min: 3)('ab'), isNotNull);
      expect(V.length(min: 3)('abc'), isNull);
    });

    test('целое число проверяет границы', () {
      expect(V.integer(min: 1450, max: 2100)('abc'), isNotNull);
      expect(V.integer(min: 1450, max: 2100)('1200'), isNotNull);
      expect(V.integer(min: 1450, max: 2100)('1869'), isNull);
    });
  });

  group('ISBN и почта', () {
    test('ISBN принимает 10 и 13 цифр', () {
      expect(V.isbn()('9781234567890'), isNull);
      expect(V.isbn()('123'), isNotNull);
    });

    test('почта отклоняет мусор', () {
      expect(V.email()('not-mail'), isNotNull);
      expect(V.email()('a@b.c'), isNull);
    });
  });

  group('Разбор модели', () {
    test('отсутствующие поля книги не приводят к исключению', () {
      final book = Book.fromJson({'id': 1});
      expect(book.title, '');
      expect(book.authorIds, isEmpty);
    });

    test('пользователь читается из неполного json', () {
      final user = AppUser.fromJson({'username': 'reader'});
      expect(user.displayName, 'reader');
      expect(user.role, Role.reader);
    });
  });
}
