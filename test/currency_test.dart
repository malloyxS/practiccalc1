import 'package:flutter_test/flutter_test.dart';

import 'package:calc_web/logic/currency.dart';

void main() {
  test('конвертирует доллары в рубли по константному курсу', () {
    final result = convertCurrency(from: 'USD', to: 'RUB', amount: '2');
    expect(result, isA<ConvertSuccess>());
    expect((result as ConvertSuccess).value, 181);
  });

  test('при одинаковых валютах сумма не меняется', () {
    final result = convertCurrency(from: 'EUR', to: 'EUR', amount: '50');
    expect((result as ConvertSuccess).value, 50);
  });

  test('принимает запятую в сумме', () {
    final result = convertCurrency(from: 'USD', to: 'RUB', amount: '1,5');
    expect((result as ConvertSuccess).value, closeTo(135.75, 0.0001));
  });

  test('возвращает ошибку при неизвестной валюте', () {
    final result = convertCurrency(from: 'USD', to: 'BTC', amount: '1');
    expect((result as ConvertFailure).message, 'Неизвестная валюта');
  });

  test('возвращает ошибку при нечисловой сумме', () {
    final result = convertCurrency(from: 'USD', to: 'RUB', amount: 'много');
    expect((result as ConvertFailure).message, 'В адресе передано не число');
  });

  test('возвращает ошибку при отсутствии параметра', () {
    final result = convertCurrency(from: 'USD', to: 'RUB', amount: null);
    expect(
      (result as ConvertFailure).message,
      'В адресе не хватает обязательных параметров',
    );
  });
}
