class Currency {
  final String code;
  final String name;

  /// Сколько рублей стоит одна единица этой валюты.
  final double rubPerUnit;

  const Currency({
    required this.code,
    required this.name,
    required this.rubPerUnit,
  });
}

const List<Currency> currencies = [
  Currency(code: 'RUB', name: 'Российский рубль', rubPerUnit: 1),
  Currency(code: 'USD', name: 'Доллар США', rubPerUnit: 90.50),
  Currency(code: 'EUR', name: 'Евро', rubPerUnit: 98.20),
  Currency(code: 'GBP', name: 'Фунт стерлингов', rubPerUnit: 115.40),
  Currency(code: 'CNY', name: 'Китайский юань', rubPerUnit: 12.60),
  Currency(code: 'JPY', name: 'Японская иена', rubPerUnit: 0.61),
];

Currency? findCurrency(String? code) {
  if (code == null || code.isEmpty) {
    return null;
  }
  for (final currency in currencies) {
    if (currency.code == code) {
      return currency;
    }
  }
  return null;
}

sealed class ConvertResult {
  const ConvertResult();
}

class ConvertSuccess extends ConvertResult {
  final double amount;
  final Currency from;
  final Currency to;
  final double value;

  const ConvertSuccess({
    required this.amount,
    required this.from,
    required this.to,
    required this.value,
  });
}

class ConvertFailure extends ConvertResult {
  final String message;

  const ConvertFailure(this.message);
}

ConvertResult convertCurrency({
  required String? from,
  required String? to,
  required String? amount,
}) {
  if (_isMissing(from) || _isMissing(to) || _isMissing(amount)) {
    return const ConvertFailure('В адресе не хватает обязательных параметров');
  }

  final fromCurrency = findCurrency(from);
  final toCurrency = findCurrency(to);
  if (fromCurrency == null || toCurrency == null) {
    return const ConvertFailure('Неизвестная валюта');
  }

  final value = double.tryParse(amount!.replaceAll(',', '.'));
  if (value == null) {
    return const ConvertFailure('В адресе передано не число');
  }
  if (value < 0) {
    return const ConvertFailure('Сумма не может быть отрицательной');
  }

  final result = value * fromCurrency.rubPerUnit / toCurrency.rubPerUnit;
  return ConvertSuccess(
    amount: value,
    from: fromCurrency,
    to: toCurrency,
    value: result,
  );
}

bool _isMissing(String? value) => value == null || value.trim().isEmpty;
