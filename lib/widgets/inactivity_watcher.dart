import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/session_config.dart';
import '../state/auth_notifier.dart';

class InactivityWatcher extends StatefulWidget {
  final AuthNotifier auth;
  final Widget child;

  const InactivityWatcher({super.key, required this.auth, required this.child});

  @override
  State<InactivityWatcher> createState() => _InactivityWatcherState();
}

class _InactivityWatcherState extends State<InactivityWatcher> {
  Timer? _timer;
  bool _warningShown = false;

  Duration get _idle => const Duration(seconds: idleSeconds);
  Duration get _warn => const Duration(seconds: idleWarnSeconds);

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    widget.auth.addListener(_onAuth);
    _restart();
  }

  bool _onKey(KeyEvent event) {
    _onActivity();
    return false;
  }

  void _onAuth() {
    if (!widget.auth.isAuthenticated) {
      _timer?.cancel();
      _warningShown = false;
      return;
    }
    _restart();
  }

  void _onActivity() {
    if (!widget.auth.isAuthenticated) return;
    unawaited(widget.auth.touchActivity());
    _warningShown = false;
    _restart();
  }

  void _restart() {
    _timer?.cancel();
    if (!widget.auth.isAuthenticated) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _tick() async {
    if (!mounted || !widget.auth.isAuthenticated) return;
    if (widget.auth.sessionExpired) {
      await _finish('Истекло максимальное время сессии.');
      return;
    }
    final last = widget.auth.lastActivity ?? DateTime.now();
    final idleFor = DateTime.now().difference(last);
    if (idleFor >= _idle) {
      await _finish('Сессия завершена из-за неактивности.');
      return;
    }
    if (!_warningShown && idleFor >= _idle - _warn) {
      _warningShown = true;
      if (!mounted) return;
      try {
        final stay = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          useRootNavigator: true,
          builder: (context) => AlertDialog(
            constraints: const BoxConstraints(maxWidth: 420),
            title: const Text('Сессия скоро завершится'),
            content: Text(
              'Вы не действовали несколько минут. Через $idleWarnSeconds секунд вход будет сброшен.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Продолжить работу'),
              ),
            ],
          ),
        );
        if (stay == true) {
          _onActivity();
        }
      } catch (_) {
        _warningShown = false;
      }
    }
  }

  Future<void> _finish(String message) async {
    _timer?.cancel();
    if (!mounted) return;
    await widget.auth.logout();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    widget.auth.removeListener(_onAuth);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onActivity(),
      onPointerMove: (_) => _onActivity(),
      onPointerSignal: (_) => _onActivity(),
      child: widget.child,
    );
  }
}
