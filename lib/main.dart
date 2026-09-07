import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'repositories/author_repository.dart';
import 'repositories/book_repository.dart';
import 'repositories/in_memory_author_repository.dart';
import 'repositories/in_memory_book_repository.dart';
import 'router.dart';
import 'settings.dart';
import 'state/author_list_notifier.dart';
import 'state/book_list_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final settings = AppSettings();
  await settings.load();
  runApp(CalcApp(settings: settings));
}

class CalcApp extends StatelessWidget {
  final AppSettings settings;

  const CalcApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      settings: settings,
      child: MultiProvider(
        providers: [
          Provider<BookRepository>(create: (_) => InMemoryBookRepository()),
          Provider<AuthorRepository>(create: (_) => InMemoryAuthorRepository()),
          ChangeNotifierProvider(
            create: (context) => BookListNotifier(context.read<BookRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) => AuthorListNotifier(context.read<AuthorRepository>()),
          ),
        ],
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) {
            return MaterialApp.router(
              title: 'Учебная библиотека',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.indigo,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              themeMode: settings.themeMode,
              routerConfig: appRouter,
            );
          },
        ),
      ),
    );
  }
}
