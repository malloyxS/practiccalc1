import 'package:flutter/material.dart';

class DeferredLoader extends StatefulWidget {
  final Future<void> Function() load;
  final Widget Function() builder;

  const DeferredLoader({super.key, required this.load, required this.builder});

  @override
  State<DeferredLoader> createState() => _DeferredLoaderState();
}

class _DeferredLoaderState extends State<DeferredLoader> {
  late final Future<void> _ready;

  @override
  void initState() {
    super.initState();
    _ready = widget.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Не удалось загрузить раздел: ${snapshot.error}'),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.builder();
      },
    );
  }
}
