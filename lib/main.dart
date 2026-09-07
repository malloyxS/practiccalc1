import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'data/library_store.dart';
import 'repositories/author_repository.dart';
import 'repositories/book_repository.dart';
import 'repositories/catalog_repositories.dart';
import 'repositories/in_memory_author_repository.dart';
import 'repositories/in_memory_book_repository.dart';
import 'router.dart';
import 'settings.dart';
import 'state/author_list_notifier.dart';
import 'state/book_list_notifier.dart';
import 'state/catalog_notifiers.dart';

final _messengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final settings = AppSettings();
  await settings.load();
  final store = await LibraryStore.load();
  runApp(CalcApp(settings: settings, store: store));
}

class CalcApp extends StatefulWidget {
  final AppSettings settings;
  final LibraryStore store;

  const CalcApp({super.key, required this.settings, required this.store});

  @override
  State<CalcApp> createState() => _CalcAppState();
}

class _CalcAppState extends State<CalcApp> {
  @override
  void initState() {
    super.initState();
    final message = widget.store.restoreMessage;
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
        widget.store.restoreMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return SettingsScope(
      settings: widget.settings,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<LibraryStore>.value(value: store),
          Provider<BookRepository>(create: (_) => InMemoryBookRepository(store)),
          Provider<AuthorRepository>(create: (_) => InMemoryAuthorRepository(store)),
          Provider<GenreRepository>(create: (_) => InMemoryGenreRepository(store)),
          Provider<PublisherRepository>(create: (_) => InMemoryPublisherRepository(store)),
          Provider<ReaderRepository>(create: (_) => InMemoryReaderRepository(store)),
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
          listenable: widget.settings,
          builder: (context, _) {
            return MaterialApp.router(
              title: 'Учебная библиотека',
              debugShowCheckedModeBanner: false,
              scaffoldMessengerKey: _messengerKey,
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
              themeMode: widget.settings.themeMode,
              routerConfig: appRouter,
            );
          },
        ),
      ),
    );
  }
}
