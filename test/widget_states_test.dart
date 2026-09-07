import 'package:calc_web/auth/auth_api.dart';
import 'package:calc_web/data/catalog_cache.dart';
import 'package:calc_web/data/library_store.dart';
import 'package:calc_web/models/app_user.dart';
import 'package:calc_web/models/role.dart';
import 'package:calc_web/repositories/catalog_repositories.dart';
import 'package:calc_web/repositories/in_memory_author_repository.dart';
import 'package:calc_web/repositories/in_memory_book_repository.dart';
import 'package:calc_web/screens/home_screen.dart';
import 'package:calc_web/screens/login_screen.dart';
import 'package:calc_web/settings.dart';
import 'package:calc_web/state/auth_notifier.dart';
import 'package:calc_web/widgets/list_extras.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('список показывает индикатор загрузки', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ListStatusView(
          loading: true,
          empty: false,
          child: Text('данные'),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('данные'), findsNothing);
  });

  testWidgets('список показывает пустой результат', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ListStatusView(
          loading: false,
          empty: true,
          emptyText: 'Книг не найдено',
          child: Text('данные'),
        ),
      ),
    );
    expect(find.text('Книг не найдено'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('ошибка показывает кнопку повтора', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ListStatusView(
          loading: false,
          empty: false,
          error: 'Сервер недоступен',
          onRetry: () => retried = true,
          child: const Text('данные'),
        ),
      ),
    );
    expect(find.text('Сервер недоступен'), findsOneWidget);
    await tester.tap(find.text('Повторить'));
    expect(retried, isTrue);
  });

  testWidgets('форма входа не отправляется без логина', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthNotifier(prefs, AuthApi(Dio()));
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: auth,
          child: const LoginScreen(),
        ),
      ),
    );
    await tester.tap(find.text('Войти'));
    await tester.pump();
    expect(find.text('Укажите логин'), findsOneWidget);
  });

  testWidgets('кнопка пользователей скрыта у читателя', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthNotifier(prefs, AuthApi(Dio()));
    auth.debugAssign(
      const AppUser(
        id: 1,
        username: 'reader',
        displayName: 'Анна Читатель',
        role: Role.reader,
        readerId: 2,
      ),
    );
    final store = LibraryStore.memory();
    final cache = CatalogCache(
      authors: InMemoryAuthorRepository(store),
      genres: InMemoryGenreRepository(store),
      publishers: InMemoryPublisherRepository(store),
      books: InMemoryBookRepository(store),
    )..loaded = true;
    final settings = AppSettings();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/books', builder: (_, _) => const SizedBox()),
        GoRoute(path: '/my-loans', builder: (_, _) => const SizedBox()),
        GoRoute(path: '/calculator', builder: (_, _) => const SizedBox()),
        GoRoute(path: '/converter', builder: (_, _) => const SizedBox()),
      ],
    );
    await tester.pumpWidget(
      SettingsScope(
        settings: settings,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider.value(value: cache),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Пользователи'), findsNothing);
    expect(find.text('Мои выдачи'), findsOneWidget);
  });
}
