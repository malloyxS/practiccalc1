import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'data/catalog_cache.dart';
import 'repositories/api_author_repository.dart';
import 'repositories/api_book_repository.dart';
import 'repositories/api_catalog_repositories.dart';
import 'repositories/author_repository.dart';
import 'repositories/book_repository.dart';
import 'repositories/catalog_repositories.dart';
import 'router.dart';
import 'settings.dart';
import 'state/author_list_notifier.dart';
import 'state/book_list_notifier.dart';
import 'state/catalog_notifiers.dart';

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
          Provider<Dio>(create: (_) => buildDio()),
          Provider<BookRepository>(create: (context) => ApiBookRepository(context.read<Dio>())),
          Provider<AuthorRepository>(create: (context) => ApiAuthorRepository(context.read<Dio>())),
          Provider<GenreRepository>(create: (context) => ApiGenreRepository(context.read<Dio>())),
          Provider<PublisherRepository>(create: (context) => ApiPublisherRepository(context.read<Dio>())),
          Provider<ReaderRepository>(create: (context) => ApiReaderRepository(context.read<Dio>())),
          ChangeNotifierProvider(
            create: (context) {
              final dio = context.read<Dio>();
              return CatalogCache(
                authors: ApiAuthorRepository(dio),
                genres: ApiGenreRepository(dio),
                publishers: ApiPublisherRepository(dio),
                books: ApiBookRepository(dio),
              )..ensureLoaded();
            },
          ),
          ChangeNotifierProvider(
            create: (context) => BookListNotifier(context.read<BookRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) => AuthorListNotifier(context.read<AuthorRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) => GenreListNotifier(context.read<GenreRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) => PublisherListNotifier(context.read<PublisherRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) => ReaderListNotifier(context.read<ReaderRepository>()),
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
