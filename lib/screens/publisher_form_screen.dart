import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/validators.dart';
import '../models/author.dart';
import '../repositories/catalog_repositories.dart';
import '../state/catalog_notifiers.dart';
import '../widgets/entity_form.dart';

class PublisherFormScreen extends StatefulWidget {
  final int? id;

  const PublisherFormScreen({super.key, this.id});

  @override
  State<PublisherFormScreen> createState() => _PublisherFormScreenState();
}

class _PublisherFormScreenState extends State<PublisherFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _foundedYear = TextEditingController();
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
    final publisher = await context.read<PublisherRepository>().findById(widget.id!);
    if (!mounted || publisher == null) {
      setState(() => _loading = false);
      return;
    }
    _name.text = publisher.name;
    _city.text = publisher.city;
    _foundedYear.text = '${publisher.foundedYear}';
    setState(() {
      _deletedAt = publisher.deletedAt;
      _loading = false;
    });
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final publisher = Publisher(
      id: widget.id ?? 0,
      name: _name.text.trim(),
      city: _city.text.trim(),
      foundedYear: int.parse(_foundedYear.text.trim()),
      deletedAt: _deletedAt,
    );
    final repo = context.read<PublisherRepository>();
    widget.id == null ? await repo.create(publisher) : await repo.update(publisher);
    if (!mounted) return;
    await context.read<PublisherListNotifier>().load();
    if (!mounted) return;
    context.go('/publishers');
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _foundedYear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: EntityFormScaffold(
        title: widget.id == null ? 'Новое издательство' : 'Редактирование издательства',
        dirty: _dirty,
        loading: _loading,
        backPath: '/publishers',
        saveLabel: widget.id == null ? 'Создать' : 'Сохранить',
        onSave: _save,
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
            validator: V.all([V.required('Укажите название'), V.length(min: 2, max: 120)]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _city,
            decoration: const InputDecoration(labelText: 'Город', border: OutlineInputBorder()),
            validator: V.all([V.required('Укажите город'), V.length(min: 2, max: 80)]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _foundedYear,
            decoration: const InputDecoration(labelText: 'Год основания', border: OutlineInputBorder()),
            validator: V.all([V.required(), V.integer(min: 1400, max: 2026)]),
            onChanged: (_) => _markDirty(),
          ),
        ],
      ),
    );
  }
}
