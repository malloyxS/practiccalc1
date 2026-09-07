import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/loan.dart';
import '../repositories/loan_repository.dart';
import '../widgets/app_chrome.dart';
import '../widgets/list_extras.dart';

class MyLoansScreen extends StatefulWidget {
  const MyLoansScreen({super.key});

  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen> {
  List<Loan> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await context.read<LoanRepository>().mine();
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _extend(Loan loan) async {
    try {
      await context.read<LoanRepository>().extend(loan.id);
      if (!mounted) return;
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Мои выдачи'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListStatusView(
          loading: _loading,
          empty: !_loading && _items.isEmpty,
          error: _error,
          onRetry: _load,
          child: ListView.separated(
            itemCount: _items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final loan = _items[index];
              return Card(
                child: ListTile(
                  title: Text(loan.bookTitle),
                  subtitle: Text(
                    loan.isActive
                        ? 'До ${loan.dueAt.toIso8601String().substring(0, 10)}${loan.extended ? ' · уже продлено' : ''}'
                        : 'Возвращено ${loan.returnedAt!.toIso8601String().substring(0, 10)}',
                  ),
                  trailing: loan.isActive && !loan.extended
                      ? TextButton(
                          onPressed: () => _extend(loan),
                          child: const Text('Продлить'),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
