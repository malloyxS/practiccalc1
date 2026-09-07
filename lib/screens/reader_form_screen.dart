import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../core/validators.dart';
import '../models/reader.dart';
import '../repositories/catalog_repositories.dart';
import '../state/catalog_notifiers.dart';
import '../widgets/entity_form.dart';

class ReaderFormScreen extends StatefulWidget {
  final int? id;

  const ReaderFormScreen({super.key, this.id});

  @override
  State<ReaderFormScreen> createState() => _ReaderFormScreenState();
}

class _ReaderFormScreenState extends State<ReaderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _cardNumber = TextEditingController();
  final _issuedAt = TextEditingController();
  final _expiresAt = TextEditingController();
  bool _cardActive = true;
  bool _loading = false;
  bool _saving = false;
  bool _dirty = false;
  String? _emailUniqueError;
  DateTime? _deletedAt;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    } else {
      final now = DateTime.now();
      _issuedAt.text = _fmt(now);
      _expiresAt.text = _fmt(DateTime(now.year + 1, now.month, now.day));
    }
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _load() async {
    final reader = await context.read<ReaderRepository>().findById(widget.id!);
    if (!mounted || reader == null) {
      setState(() => _loading = false);
      return;
    }
    _lastName.text = reader.lastName;
    _firstName.text = reader.firstName;
    _email.text = reader.email;
    _phone.text = reader.phone;
    _cardNumber.text = reader.card.number;
    _issuedAt.text = _fmt(reader.card.issuedAt);
    _expiresAt.text = _fmt(reader.card.expiresAt);
    setState(() {
      _cardActive = reader.card.active;
      _deletedAt = reader.deletedAt;
      _loading = false;
    });
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _emailUniqueError = null);
    if (!_formKey.currentState!.validate()) return;
    final issued = DateTime.parse(_issuedAt.text.trim());
    final expires = DateTime.parse(_expiresAt.text.trim());
    if (!expires.isAfter(issued)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Срок действия должен быть позже даты выдачи'),
        ),
      );
      return;
    }
    final reader = Reader(
      id: widget.id ?? 0,
      lastName: _lastName.text.trim(),
      firstName: _firstName.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      card: LibraryCard(
        number: _cardNumber.text.trim(),
        issuedAt: issued,
        expiresAt: expires,
        active: _cardActive,
      ),
      deletedAt: _deletedAt,
    );
    setState(() => _saving = true);
    try {
      final repo = context.read<ReaderRepository>();
      widget.id == null ? await repo.create(reader) : await repo.update(reader);
      if (!mounted) return;
      await context.read<ReaderListNotifier>().load();
      if (!mounted) return;
      context.go('/readers');
    } on ValidationException catch (e) {
      setState(() {
        _saving = false;
        _emailUniqueError = e.errors['email'];
      });
      _formKey.currentState?.validate();
    } on ApiException catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  void dispose() {
    _lastName.dispose();
    _firstName.dispose();
    _email.dispose();
    _phone.dispose();
    _cardNumber.dispose();
    _issuedAt.dispose();
    _expiresAt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: EntityFormScaffold(
        title: widget.id == null ? 'Новый читатель' : 'Редактирование читателя',
        dirty: _dirty,
        loading: _loading,
        saving: _saving,
        backPath: '/readers',
        saveLabel: widget.id == null ? 'Создать' : 'Сохранить',
        onSave: _save,
        children: [
          TextFormField(
            controller: _lastName,
            decoration: const InputDecoration(
              labelText: 'Фамилия',
              border: OutlineInputBorder(),
            ),
            validator: V.all([
              V.required('Укажите фамилию'),
              V.length(min: 2, max: 80),
            ]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _firstName,
            decoration: const InputDecoration(
              labelText: 'Имя',
              border: OutlineInputBorder(),
            ),
            validator: V.all([
              V.required('Укажите имя'),
              V.length(min: 2, max: 80),
            ]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: V.all([
              V.required('Укажите email'),
              V.email(),
              (_) => _emailUniqueError,
            ]),
            onChanged: (_) {
              _emailUniqueError = null;
              _markDirty();
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phone,
            decoration: const InputDecoration(
              labelText: 'Телефон',
              border: OutlineInputBorder(),
            ),
            validator: V.all([
              V.required('Укажите телефон'),
              V.length(min: 6, max: 20),
            ]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 24),
          Text(
            'Читательский билет',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cardNumber,
            decoration: const InputDecoration(
              labelText: 'Номер билета',
              border: OutlineInputBorder(),
            ),
            validator: V.all([
              V.required('Укажите номер билета'),
              V.length(min: 4, max: 20),
            ]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _issuedAt,
            decoration: const InputDecoration(
              labelText: 'Дата выдачи (ГГГГ-ММ-ДД)',
              border: OutlineInputBorder(),
            ),
            validator: V.all([V.required(), V.date()]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _expiresAt,
            decoration: const InputDecoration(
              labelText: 'Действует до (ГГГГ-ММ-ДД)',
              border: OutlineInputBorder(),
            ),
            validator: V.all([V.required(), V.date()]),
            onChanged: (_) => _markDirty(),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Билет активен'),
            value: _cardActive,
            onChanged: (value) => setState(() {
              _cardActive = value;
              _dirty = true;
            }),
          ),
        ],
      ),
    );
  }
}
