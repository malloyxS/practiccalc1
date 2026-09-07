import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/validators.dart';
import '../models/author.dart';
import '../repositories/author_repository.dart';
import '../state/author_list_notifier.dart';
import '../widgets/entity_form.dart';

class AuthorFormScreen extends StatefulWidget {
  final int? id;

  const AuthorFormScreen({super.key, this.id});

  @override
  State<AuthorFormScreen> createState() => _AuthorFormScreenState();
}

class _AuthorFormScreenState extends State<AuthorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _country = TextEditingController();
  final _birthYear = TextEditingController();
  bool _loading = false;
  bool _dirty = false;
  DateTime? _deletedAt;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  Future<void> _load() async {
    final author = await context.read<AuthorRepository>().findById(widget.id!);
    if (!mounted || author == null) {
      setState(() => _loading = false);
      return;
    }
    _lastName.text = author.lastName;
    _firstName.text = author.firstName;
    _country.text = author.country;
    _birthYear.text = '${author.birthYear}';
    setState(() {
      _deletedAt = author.deletedAt;
      _loading = false;
    });
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final author = Author(
      id: widget.id ?? 0,
      lastName: _lastName.text.trim(),
      firstName: _firstName.text.trim(),
      country: _country.text.trim(),
      birthYear: int.parse(_birthYear.text.trim()),
      deletedAt: _deletedAt,
    );
    final repo = context.read<AuthorRepository>();
    widget.id == null ? await repo.create(author) : await repo.update(author);
    if (!mounted) return;
    await context.read<AuthorListNotifier>().load();
    if (!mounted) return;
    context.go('/authors');
  }

  @override
  void dispose() {
    _lastName.dispose();
    _firstName.dispose();
    _country.dispose();
    _birthYear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: EntityFormScaffold(
        title: widget.id == null ? 'Новый автор' : 'Редактирование автора',
        dirty: _dirty,
        loading: _loading,
        backPath: '/authors',
        saveLabel: widget.id == null ? 'Создать' : 'Сохранить',
        onSave: _save,
        children: [
          TextFormField(
            controller: _lastName,
            decoration: const InputDecoration(labelText: 'Фамилия', border: OutlineInputBorder()),
            validator: V.all([V.required('Укажите фамилию'), V.length(min: 2, max: 80)]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _firstName,
            decoration: const InputDecoration(labelText: 'Имя', border: OutlineInputBorder()),
            validator: V.all([V.required('Укажите имя'), V.length(min: 2, max: 80)]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _country,
            decoration: const InputDecoration(labelText: 'Страна', border: OutlineInputBorder()),
            validator: V.all([V.required('Укажите страну'), V.length(min: 2, max: 80)]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _birthYear,
            decoration: const InputDecoration(labelText: 'Год рождения', border: OutlineInputBorder()),
            validator: V.all([V.required(), V.integer(min: 1400, max: 2020)]),
            onChanged: (_) => _markDirty(),
          ),
        ],
      ),
    );
  }
}
