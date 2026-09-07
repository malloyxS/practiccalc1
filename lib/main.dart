import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/auth_api.dart';
import 'core/api_client.dart';
import 'core/auth_interceptor.dart';
import 'data/catalog_cache.dart';
import 'repositories/api_author_repository.dart';
import 'repositories/api_book_repository.dart';
import 'repositories/api_catalog_repositories.dart';
import 'repositories/author_repository.dart';
import 'repositories/book_repository.dart';
import 'repositories/catalog_repositories.dart';
import 'repositories/loan_repository.dart';
import 'repositories/user_repository.dart';
import 'router.dart';
import 'settings.dart';
import 'state/auth_notifier.dart';
import 'state/author_list_notifier.dart';
import 'state/book_list_notifier.dart';
import 'state/catalog_notifiers.dart';
import 'state/connection_notifier.dart';
import 'widgets/inactivity_watcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final settings = AppSettings();
  await settings.load();
  final prefs = await SharedPreferences.getInstance();
  late final AuthNotifier auth;
  final dio = buildDio(tokenProvider: () => auth.accessToken);
  auth = AuthNotifier(prefs, AuthApi(dio));
  attachRefreshInterceptor(dio, auth);
  await auth.restore();
  runApp(CalcApp(settings: settings, auth: auth, dio: dio));
}

class CalcApp extends StatelessWidget {
  final AppSettings settings;
  final AuthNotifier auth;
  final Dio dio;

  const CalcApp({
    super.key,
    required this.settings,
    required this.auth,
    required this.dio,
  });

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(auth);
    return SettingsScope(
      settings: settings,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthNotifier>.value(value: auth),
          Provider<Dio>.value(value: dio),
          Provider<BookRepository>(
            create: (context) => ApiBookRepository(context.read<Dio>()),
          ),
          Provider<AuthorRepository>(
            create: (context) => ApiAuthorRepository(context.read<Dio>()),
          ),
          Provider<GenreRepository>(
            create: (context) => ApiGenreRepository(context.read<Dio>()),
          ),
          Provider<PublisherRepository>(
            create: (context) => ApiPublisherRepository(context.read<Dio>()),
          ),
          Provider<ReaderRepository>(
            create: (context) => ApiReaderRepository(context.read<Dio>()),
          ),
          Provider<LoanRepository>(
            create: (context) => LoanRepository(context.read<Dio>()),
          ),
          Provider<UserRepository>(
            create: (context) => UserRepository(context.read<Dio>()),
          ),
          ChangeNotifierProvider(
            create: (context) {
              final client = context.read<Dio>();
              return CatalogCache(
                authors: ApiAuthorRepository(client),
                genres: ApiGenreRepository(client),
                publishers: ApiPublisherRepository(client),
                books: ApiBookRepository(client),
              )..ensureLoaded();
            },
          ),
          ChangeNotifierProvider(
            create: (context) =>
                BookListNotifier(context.read<BookRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                AuthorListNotifier(context.read<AuthorRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                GenreListNotifier(context.read<GenreRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                PublisherListNotifier(context.read<PublisherRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                ReaderListNotifier(context.read<ReaderRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) => ConnectionNotifier(context.read<Dio>()),
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
              routerConfig: router,
              builder: (context, child) {
                return InactivityWatcher(
                  auth: auth,
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
