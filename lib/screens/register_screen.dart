import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../core/validators.dart';
import '../state/auth_notifier.dart';
import '../widgets/app_chrome.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _saving = false;
  String? _error;

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<AuthNotifier>().register(
        username: _username.text.trim(),
        password: _password.text,
        displayName: _name.text.trim(),
      );
      if (!mounted) return;
      context.go('/');
    } on ValidationException catch (e) {
      setState(() {
        _saving = false;
        _error = e.errors.values.join('\n');
        if (_error!.isEmpty) _error = e.message;
      });
    } on ApiException catch (e) {
      setState(() {
        _saving = false;
        _error = e.message;
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rules = V.passwordRules(_password.text);
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: NarrowBody(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  border: OutlineInputBorder(),
                ),
                validator: V.all([
                  V.required('Укажите имя'),
                  V.length(min: 2, max: 80),
                ]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(
                  labelText: 'Логин',
                  border: OutlineInputBorder(),
                ),
                validator: V.all([
                  V.required('Укажите логин'),
                  V.length(min: 3, max: 40),
                ]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
                validator: V.all([V.required('Укажите пароль'), V.password()]),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _Rule(ok: rules.longEnough, text: 'Не менее 8 символов'),
              _Rule(ok: rules.hasDigit, text: 'Есть цифра'),
              _Rule(ok: rules.hasSpecial, text: 'Есть специальный символ'),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _submit,
                child: Text(_saving ? 'Создание...' : 'Зарегистрироваться'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Уже есть учётка — войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  final bool ok;
  final String text;

  const _Rule({required this.ok, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: ok ? Colors.green : null,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
