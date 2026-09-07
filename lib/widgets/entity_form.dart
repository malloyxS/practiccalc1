import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_chrome.dart';
import 'list_extras.dart';

class EntityFormScaffold extends StatelessWidget {
  final String title;
  final bool dirty;
  final bool loading;
  final bool saving;
  final VoidCallback onSave;
  final String saveLabel;
  final List<Widget> children;
  final String backPath;

  const EntityFormScaffold({
    super.key,
    required this.title,
    required this.dirty,
    required this.onSave,
    required this.children,
    required this.backPath,
    this.loading = false,
    this.saving = false,
    this.saveLabel = 'Сохранить',
  });

  Future<void> _leave(BuildContext context) async {
    if (!dirty) {
      context.go(backPath);
      return;
    }
    final ok = await confirmAction(
      context,
      title: 'Несохранённые изменения',
      message: 'Покинуть форму без сохранения?',
    );
    if (ok && context.mounted) context.go(backPath);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _leave(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _leave(context),
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : NarrowBody(
                maxWidth: 640,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...children,
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: saving ? null : onSave,
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(saveLabel),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _leave(context),
                      child: const Text('Отмена'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class ChipMultiSelect extends StatelessWidget {
  final String label;
  final List<({int id, String label})> options;
  final List<int> value;
  final ValueChanged<List<int>> onChanged;
  final String? Function(List<int>?)? validator;

  const ChipMultiSelect({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<List<int>>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            errorText: field.errorText,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                FilterChip(
                  label: Text(option.label),
                  selected: field.value!.contains(option.id),
                  onSelected: (_) {
                    final next = [...field.value!];
                    next.contains(option.id) ? next.remove(option.id) : next.add(option.id);
                    field.didChange(next);
                    onChanged(next);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
