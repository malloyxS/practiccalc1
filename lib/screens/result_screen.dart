import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/calculator.dart';
import '../logic/currency.dart';
import '../widgets/app_chrome.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final query = state.uri.queryParameters;
    final isConverter = state.uri.path.startsWith('/converter');

    if (isConverter) {
      return _ConverterResult(query: query);
    }
    return _CalculatorResult(query: query);
  }
}

class _CalculatorResult extends StatelessWidget {
  final Map<String, String> query;

  const _CalculatorResult({required this.query});

  @override
  Widget build(BuildContext context) {
    final result = calculate(query['a'], query['op'], query['b']);
    final expression = '${query['a'] ?? '?'} ${query['op'] ?? '?'} ${query['b'] ?? '?'}';

    return switch (result) {
      CalcSuccess(:final value) => _ResultScaffold(
        title: 'Результат вычисления',
        backPath: '/calculator',
        child: _SuccessCard(
          headline: expression,
          value: formatNumber(value),
        ),
      ),
      CalcFailure(:final message) => _ResultScaffold(
        title: 'Результат вычисления',
        backPath: '/calculator',
        child: _ErrorCard(message: message),
      ),
    };
  }
}

class _ConverterResult extends StatelessWidget {
  final Map<String, String> query;

  const _ConverterResult({required this.query});

  @override
  Widget build(BuildContext context) {
    final result = convertCurrency(
      from: query['from'],
      to: query['to'],
      amount: query['amount'],
    );

    return switch (result) {
      ConvertSuccess(:final amount, :final from, :final to, :final value) =>
        _ResultScaffold(
          title: 'Результат конвертации',
          backPath: '/converter',
          child: _SuccessCard(
            headline:
                '${formatNumber(amount)} ${from.code} → ${to.code}',
            value: '${formatNumber(value)} ${to.code}',
          ),
        ),
      ConvertFailure(:final message) => _ResultScaffold(
        title: 'Результат конвертации',
        backPath: '/converter',
        child: _ErrorCard(message: message),
      ),
    };
  }
}

class _ResultScaffold extends StatelessWidget {
  final String title;
  final String backPath;
  final Widget child;

  const _ResultScaffold({
    required this.title,
    required this.backPath,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, title),
      body: NarrowBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            child,
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.go(backPath),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Вернуться к форме'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final String headline;
  final String value;

  const _SuccessCard({required this.headline, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              headline,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
