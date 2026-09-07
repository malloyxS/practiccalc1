import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/app_user.dart';
import '../models/role.dart';
import '../repositories/user_repository.dart';
import '../widgets/app_chrome.dart';
import '../widgets/list_extras.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<AppUser> _items = [];
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
      final items = await context.read<UserRepository>().find();
      if (!mounted) return;
      setState(() {
        _items = items;
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

  Future<void> _changeRole(AppUser user, Role role) async {
    try {
      await context.read<UserRepository>().updateRole(user.id, role);
      if (!mounted) return;
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Пользователи'),
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
              final user = _items[index];
              return Card(
                child: ListTile(
                  title: Text(user.displayName),
                  subtitle: Text('${user.username} · ${user.role.title}'),
                  trailing: DropdownButton<Role>(
                    value: user.role,
                    items: [
                      for (final role in Role.values)
                        DropdownMenuItem(value: role, child: Text(role.title)),
                    ],
                    onChanged: (role) {
                      if (role != null) _changeRole(user, role);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  LibraryStats? _stats;
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
      final stats = await context.read<UserRepository>().stats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
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

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    return Scaffold(
      appBar: buildAppBar(context, 'Статистика'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListStatusView(
          loading: _loading,
          empty: false,
          error: _error,
          onRetry: _load,
          child: stats == null
              ? const SizedBox.shrink()
              : ListView(
                  children: [
                    _StatTile(label: 'Книг', value: '${stats.books}'),
                    _StatTile(label: 'Авторов', value: '${stats.authors}'),
                    _StatTile(label: 'Читателей', value: '${stats.readers}'),
                    _StatTile(label: 'Активных выдач', value: '${stats.activeLoans}'),
                    _StatTile(label: 'Учёток', value: '${stats.users}'),
                  ],
                ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
