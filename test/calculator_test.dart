import 'package:flutter_test/flutter_test.dart';

import 'package:calc_web/logic/calculator.dart';

void main() {
  group('calculate', () {
    test('складывает два числа', () {
      final result = calculate('2', '+', '2');
      expect(result, isA<CalcSuccess>());
      expect((result as CalcSuccess).value, 4);
    });

    test('вычитает два числа', () {
      final result = calculate('10', '-', '3');
      expect((result as CalcSuccess).value, 7);
    });

    test('умножает два числа', () {
      final result = calculate('3', '*', '4');
      expect((result as CalcSuccess).value, 12);
    });

    test('делит два числа', () {
      final result = calculate('10', '/', '4');
      expect((result as CalcSuccess).value, 2.5);
    });

    test('принимает запятую как десятичный разделитель', () {
      final result = calculate('1,5', '+', '2,5');
      expect((result as CalcSuccess).value, 4);
    });

    test('возвращает ошибку при делении на ноль', () {
      final result = calculate('8', '/', '0');
      expect(result, isA<CalcFailure>());
      expect((result as CalcFailure).message, 'Деление на ноль невозможно');
    });

    test('возвращает ошибку при нечисловом вводе', () {
      final result = calculate('abc', '+', '2');
      expect(result, isA<CalcFailure>());
      expect((result as CalcFailure).message, 'В адресе переданы не числа');
    });

    test('возвращает ошибку при неизвестной операции', () {
      final result = calculate('1', '%', '2');
      expect(result, isA<CalcFailure>());
      expect((result as CalcFailure).message, 'Неизвестная операция');
    });

    test('возвращает ошибку при отсутствии параметра', () {
      final result = calculate('1', '+', null);
      expect(result, isA<CalcFailure>());
      expect(
        (result as CalcFailure).message,
        'В адресе не хватает обязательных параметров',
      );
    });
  });

  group('formatNumber', () {
    test('убирает хвост двоичной дроби', () {
      expect(formatNumber(10 / 3), isNot('3.3333333333333335'));
      expect(formatNumber(10 / 3), '3.33333333');
    });

    test('печатает целое без десятичной части', () {
      expect(formatNumber(4.0), '4');
    });
  });
}
