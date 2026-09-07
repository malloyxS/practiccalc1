import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ConnectionNotifier extends ChangeNotifier {
  final Dio _dio;
  Timer? _timer;
  bool _online = true;

  ConnectionNotifier(this._dio) {
    unawaited(check());
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => check());
  }

  bool get online => _online;

  Future<void> check() async {
    try {
      await _dio.get<Map<String, dynamic>>('/__health');
      _setOnline(true);
    } catch (_) {
      _setOnline(false);
    }
  }

  void _setOnline(bool value) {
    if (_online == value) return;
    _online = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
