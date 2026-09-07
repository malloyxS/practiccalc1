/// Результат вычисления: либо значение, либо описание ошибки.
sealed class CalcResult {
  const CalcResult();
}

class CalcSuccess extends CalcResult {
  final double value;

  const CalcSuccess(this.value);
}

class CalcFailure extends CalcResult {
  final String message;

  const CalcFailure(this.message);
}

CalcResult calculate(String? rawA, String? rawOp, String? rawB) {
  if (_isMissing(rawA) || _isMissing(rawOp) || _isMissing(rawB)) {
    return const CalcFailure('В адресе не хватает обязательных параметров');
  }

  final a = double.tryParse(rawA!.replaceAll(',', '.'));
  final b = double.tryParse(rawB!.replaceAll(',', '.'));
  if (a == null || b == null) {
    return const CalcFailure('В адресе переданы не числа');
  }

  return switch (rawOp) {
    '+' => CalcSuccess(a + b),
    '-' => CalcSuccess(a - b),
    '*' => CalcSuccess(a * b),
    '/' =>
      b == 0
          ? const CalcFailure('Деление на ноль невозможно')
          : CalcSuccess(a / b),
    _ => const CalcFailure('Неизвестная операция'),
  };
}

bool _isMissing(String? value) => value == null || value.trim().isEmpty;

/// Округляет результат до разумного числа знаков, без «хвоста» double.
String formatNumber(double value) {
  if (value.isNaN || value.isInfinite) {
    return value.toString();
  }
  if (value == 0) {
    return '0';
  }

  final abs = value.abs();
  if (abs >= 1e12 || abs < 1e-8) {
    return value.toStringAsExponential(6);
  }

  var text = value.toStringAsFixed(8);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
  }
  return text;
}
