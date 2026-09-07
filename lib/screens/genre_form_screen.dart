import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/validators.dart';
import '../models/author.dart';
import '../repositories/catalog_repositories.dart';
import '../state/catalog_notifiers.dart';
import '../widgets/entity_form.dart';

class GenreFormScreen extends StatefulWidget {
  final int? id;

  const GenreFormScreen({super.key, this.id});

  @override
  State<GenreFormScreen> createState() => _GenreFormScreenState();
}

class _GenreFormScreenState extends State<GenreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
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
    final genre = await context.read<GenreRepository>().findById(widget.id!);
    if (!mounted || genre == null) {
      setState(() => _loading = false);
      return;
    }
    _name.text = genre.name;
    _description.text = genre.description;
    setState(() {
      _deletedAt = genre.deletedAt;
      _loading = false;
    });
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final genre = Genre(
      id: widget.id ?? 0,
      name: _name.text.trim(),
      description: _description.text.trim(),
      deletedAt: _deletedAt,
    );
    final repo = context.read<GenreRepository>();
    widget.id == null ? await repo.create(genre) : await repo.update(genre);
    if (!mounted) return;
    await context.read<GenreListNotifier>().load();
    if (!mounted) return;
    context.go('/genres');
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: EntityFormScaffold(
        title: widget.id == null ? 'Новый жанр' : 'Редактирование жанра',
        dirty: _dirty,
        loading: _loading,
        backPath: '/genres',
        saveLabel: widget.id == null ? 'Создать' : 'Сохранить',
        onSave: _save,
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
            validator: V.all([V.required('Укажите название'), V.length(min: 2, max: 60)]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'Описание', border: OutlineInputBorder()),
            maxLines: 3,
            validator: V.length(max: 400),
            onChanged: (_) => _markDirty(),
          ),
        ],
      ),
    );
  }
}
