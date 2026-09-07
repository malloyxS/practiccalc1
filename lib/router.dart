import 'package:go_router/go_router.dart';

import 'models/book_query.dart';
import 'screens/author_form_screen.dart';
import 'screens/authors_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/book_form_screen.dart';
import 'screens/books_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/catalog_screens.dart';
import 'screens/converter_screen.dart';
import 'screens/genre_form_screen.dart';
import 'screens/home_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/publisher_form_screen.dart';
import 'screens/reader_form_screen.dart';
import 'screens/result_screen.dart';

int? _idOf(GoRouterState state) => int.tryParse(state.pathParameters['id'] ?? '');

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/books',
      builder: (context, state) => BooksScreen(query: BookQuery.fromUri(state.uri)),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const BookFormScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => BookDetailScreen(id: _idOf(state)),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => BookFormScreen(id: _idOf(state)),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/authors',
      builder: (context, state) => AuthorsScreen(query: AuthorQuery.fromUri(state.uri)),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const AuthorFormScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => AuthorDetailScreen(id: _idOf(state)),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => AuthorFormScreen(id: _idOf(state)),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/genres',
      builder: (context, state) => GenresScreen(query: CatalogQuery.fromUri(state.uri)),
      routes: [
        GoRoute(path: 'new', builder: (context, state) => const GenreFormScreen()),
        GoRoute(
          path: ':id/edit',
          builder: (context, state) => GenreFormScreen(id: _idOf(state)),
        ),
      ],
    ),
    GoRoute(
      path: '/publishers',
      builder: (context, state) => PublishersScreen(query: CatalogQuery.fromUri(state.uri)),
      routes: [
        GoRoute(path: 'new', builder: (context, state) => const PublisherFormScreen()),
        GoRoute(
          path: ':id/edit',
          builder: (context, state) => PublisherFormScreen(id: _idOf(state)),
        ),
      ],
    ),
    GoRoute(
      path: '/readers',
      builder: (context, state) =>
          ReadersScreen(query: CatalogQuery.fromUri(state.uri, defaultSort: 'lastName')),
      routes: [
        GoRoute(path: 'new', builder: (context, state) => const ReaderFormScreen()),
        GoRoute(
          path: ':id/edit',
          builder: (context, state) => ReaderFormScreen(id: _idOf(state)),
        ),
      ],
    ),
    GoRoute(
      path: '/calculator',
      builder: (context, state) => const CalculatorScreen(),
      routes: [
        GoRoute(
          path: 'result',
          builder: (context, state) => const ResultScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/converter',
      builder: (context, state) => const ConverterScreen(),
      routes: [
        GoRoute(
          path: 'result',
          builder: (context, state) => const ResultScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => NotFoundScreen(location: state.uri.toString()),
);
