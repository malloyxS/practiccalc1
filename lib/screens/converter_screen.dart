import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/currency.dart';
import '../settings.dart';
import '../widgets/app_chrome.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  late String _from;
  late String _to;
  var _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final settings = SettingsScope.of(context);
    _from = findCurrency(settings.lastFrom)?.code ?? 'USD';
    _to = findCurrency(settings.lastTo)?.code ?? 'RUB';
    _initialized = true;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите сумму';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      return 'Это не число';
    }
    if (parsed < 0) {
      return 'Сумма не может быть отрицательной';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await SettingsScope.of(context).saveCurrencyPair(_from, _to);
    if (!mounted) {
      return;
    }
    final amount = _amountController.text.trim().replaceAll(',', '.');
    context.go(
      '/converter/result?from=${Uri.encodeComponent(_from)}'
      '&to=${Uri.encodeComponent(_to)}'
      '&amount=${Uri.encodeComponent(amount)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Конвертер валют'),
      body: NarrowBody(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _from,
                decoration: const InputDecoration(
                  labelText: 'Из валюты',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final currency in currencies)
                    DropdownMenuItem(
                      value: currency.code,
                      child: Text('${currency.code} — ${currency.name}'),
                    ),
                ],
                onChanged: (value) => setState(() => _from = value ?? _from),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _to,
                decoration: const InputDecoration(
                  labelText: 'В валюту',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final currency in currencies)
                    DropdownMenuItem(
                      value: currency.code,
                      child: Text('${currency.code} — ${currency.name}'),
                    ),
                ],
                onChanged: (value) => setState(() => _to = value ?? _to),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Сумма',
                  border: OutlineInputBorder(),
                ),
                validator: _amountValidator,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: const Text('Конвертировать'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
