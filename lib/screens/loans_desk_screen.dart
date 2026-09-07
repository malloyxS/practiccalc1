import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../core/validators.dart';
import '../models/loan.dart';
import '../repositories/loan_repository.dart';
import '../widgets/app_chrome.dart';
import '../widgets/list_extras.dart';

class LoansDeskScreen extends StatefulWidget {
  const LoansDeskScreen({super.key});

  @override
  State<LoansDeskScreen> createState() => _LoansDeskScreenState();
}

class _LoansDeskScreenState extends State<LoansDeskScreen> {
  final _bookId = TextEditingController();
  final _readerId = TextEditingController();
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
      final page = await context.read<LoanRepository>().find();
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

  Future<void> _issue() async {
    final bookError = V.integer(min: 1)(_bookId.text);
    final readerError = V.integer(min: 1)(_readerId.text);
    if (bookError != null || readerError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookError ?? readerError ?? 'Проверьте поля')),
      );
      return;
    }
    try {
      await context.read<LoanRepository>().issue(
        bookId: int.parse(_bookId.text.trim()),
        readerId: int.parse(_readerId.text.trim()),
      );
      _bookId.clear();
      _readerId.clear();
      if (!mounted) return;
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _close(Loan loan) async {
    try {
      await context.read<LoanRepository>().close(loan.id);
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
  void dispose() {
    _bookId.dispose();
    _readerId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Стол выдачи'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _bookId,
                    decoration: const InputDecoration(
                      labelText: 'ID книги',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _readerId,
                    decoration: const InputDecoration(
                      labelText: 'ID читателя',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: _issue,
                  child: const Text('Оформить выдачу'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
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
                          '${loan.readerName} · до ${loan.dueAt.toIso8601String().substring(0, 10)}',
                        ),
                        trailing: loan.isActive
                            ? TextButton(
                                onPressed: () => _close(loan),
                                child: const Text('Закрыть'),
                              )
                            : const Text('возвращено'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
