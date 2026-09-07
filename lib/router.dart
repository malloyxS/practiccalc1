import 'package:go_router/go_router.dart';

import 'models/book_query.dart';
import 'screens/authors_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/books_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/home_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/result_screen.dart';

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
          path: ':id',
          builder: (context, state) => BookDetailScreen(
            id: int.tryParse(state.pathParameters['id'] ?? ''),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/authors',
      builder: (context, state) => AuthorsScreen(query: AuthorQuery.fromUri(state.uri)),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => AuthorDetailScreen(
            id: int.tryParse(state.pathParameters['id'] ?? ''),
          ),
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
  errorBuilder: (context, state) =>
      NotFoundScreen(location: state.uri.toString()),
);
