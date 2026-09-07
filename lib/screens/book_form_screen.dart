import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../core/validators.dart';
import '../data/catalog_cache.dart';
import '../models/book.dart';
import '../repositories/book_repository.dart';
import '../state/book_list_notifier.dart';
import '../widgets/entity_form.dart';

class BookFormScreen extends StatefulWidget {
  final int? id;

  const BookFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _isbn = TextEditingController();
  final _year = TextEditingController();
  final _pages = TextEditingController();
  final _copiesTotal = TextEditingController();
  final _copiesAvailable = TextEditingController();

  int? _publisherId;
  List<int> _authorIds = [];
  List<int> _genreIds = [];
  bool _loading = false;
  bool _saving = false;
  bool _dirty = false;
  String? _isbnUniqueError;
  DateTime? _deletedAt;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  Future<void> _load() async {
    try {
      final book = await context.read<BookRepository>().findById(widget.id!);
      if (!mounted) return;
      if (book == null) {
        setState(() => _loading = false);
        return;
      }
      _title.text = book.title;
      _isbn.text = book.isbn;
      _year.text = '${book.year}';
      _pages.text = '${book.pages}';
      _copiesTotal.text = '${book.copiesTotal}';
      _copiesAvailable.text = '${book.copiesAvailable}';
      setState(() {
        _publisherId = book.publisherId;
        _authorIds = [...book.authorIds];
        _genreIds = [...book.genreIds];
        _deletedAt = book.deletedAt;
        _loading = false;
        _dirty = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _isbnUniqueError = null);
    if (!_formKey.currentState!.validate()) return;
    final copiesTotal = int.parse(_copiesTotal.text.trim());
    final copiesAvailable = int.parse(_copiesAvailable.text.trim());
    if (copiesAvailable > copiesTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Доступно экземпляров не может быть больше общего числа')),
      );
      return;
    }
    final book = Book(
      id: widget.id ?? 0,
      title: _title.text.trim(),
      isbn: _isbn.text.trim(),
      year: int.parse(_year.text.trim()),
      pages: int.parse(_pages.text.trim()),
      publisherId: _publisherId!,
      authorIds: _authorIds,
      genreIds: _genreIds,
      copiesTotal: copiesTotal,
      copiesAvailable: copiesAvailable,
      deletedAt: _deletedAt,
    );
    setState(() => _saving = true);
    try {
      final repo = context.read<BookRepository>();
      if (widget.isEditing) {
        await repo.update(book);
      } else {
        await repo.create(book);
      }
      if (!mounted) return;
      await context.read<CatalogCache>().refresh();
      if (!mounted) return;
      await context.read<BookListNotifier>().load();
      if (!mounted) return;
      context.go('/books');
    } on ValidationException catch (e) {
      setState(() {
        _saving = false;
        _isbnUniqueError = e.errors['isbn'];
      });
      _formKey.currentState?.validate();
    } on ApiException catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _isbn.dispose();
    _year.dispose();
    _pages.dispose();
    _copiesTotal.dispose();
    _copiesAvailable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cache = context.watch<CatalogCache>();
    final publishers = cache.publishers.where((p) => !p.isDeleted).toList();
    final authors = cache.authorsForPublisher(_publisherId);
    final genres = cache.genresForPublisher(_publisherId);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: EntityFormScaffold(
        title: widget.isEditing ? 'Редактирование книги' : 'Новая книга',
        dirty: _dirty,
        loading: _loading,
        saving: _saving,
        backPath: '/books',
        saveLabel: widget.isEditing ? 'Сохранить' : 'Создать',
        onSave: _save,
        children: [
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
            validator: V.all([V.required('Укажите название'), V.length(min: 2, max: 200)]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _isbn,
            decoration: const InputDecoration(labelText: 'ISBN', border: OutlineInputBorder()),
            validator: V.all([
              V.required('Укажите ISBN'),
              V.isbn(),
              (_) => _isbnUniqueError,
            ]),
            onChanged: (_) {
              _isbnUniqueError = null;
              _markDirty();
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _year,
            decoration: const InputDecoration(labelText: 'Год издания', border: OutlineInputBorder()),
            validator: V.all([V.required(), V.integer(min: 1450, max: 2100)]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pages,
            decoration: const InputDecoration(labelText: 'Страниц', border: OutlineInputBorder()),
            validator: V.all([V.required(), V.integer(min: 1)]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: publishers.any((p) => p.id == _publisherId) ? _publisherId : null,
            decoration: const InputDecoration(labelText: 'Издательство', border: OutlineInputBorder()),
            items: [
              for (final publisher in publishers)
                DropdownMenuItem(value: publisher.id, child: Text(publisher.name)),
            ],
            onChanged: (value) => setState(() {
              _publisherId = value;
              final allowedAuthors = cache.authorsForPublisher(value).map((a) => a.id).toSet();
              final allowedGenres = cache.genresForPublisher(value).map((g) => g.id).toSet();
              _authorIds = _authorIds.where(allowedAuthors.contains).toList();
              _genreIds = _genreIds.where(allowedGenres.contains).toList();
              _dirty = true;
            }),
            validator: (value) => value == null ? 'Выберите издательство' : null,
          ),
          const SizedBox(height: 8),
          Text(
            'После выбора издательства списки авторов и жанров сужаются по уже связанным книгам.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ChipMultiSelect(
            key: ValueKey('authors-$_publisherId-${authors.map((a) => a.id).join(',')}'),
            label: 'Авторы',
            options: [
              for (final author in authors) (id: author.id, label: author.fullName),
            ],
            value: _authorIds,
            onChanged: (value) {
              _authorIds = value;
              _markDirty();
            },
            validator: (value) => (value == null || value.isEmpty) ? 'Выберите хотя бы одного автора' : null,
          ),
          const SizedBox(height: 16),
          ChipMultiSelect(
            key: ValueKey('genres-$_publisherId-${genres.map((g) => g.id).join(',')}'),
            label: 'Жанры',
            options: [
              for (final genre in genres) (id: genre.id, label: genre.name),
            ],
            value: _genreIds,
            onChanged: (value) {
              _genreIds = value;
              _markDirty();
            },
            validator: (value) => (value == null || value.isEmpty) ? 'Выберите хотя бы один жанр' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _copiesTotal,
            decoration: const InputDecoration(labelText: 'Всего экземпляров', border: OutlineInputBorder()),
            validator: V.all([V.required(), V.integer(min: 1)]),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _copiesAvailable,
            decoration: const InputDecoration(labelText: 'Доступно экземпляров', border: OutlineInputBorder()),
            validator: V.all([V.required(), V.integer(min: 0)]),
            onChanged: (_) => _markDirty(),
          ),
        ],
      ),
    );
  }
}
