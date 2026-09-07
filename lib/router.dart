import 'package:go_router/go_router.dart';

import 'models/book_query.dart';
import 'models/role.dart';
import 'screens/admin_screens.dart';
import 'screens/author_form_screen.dart';
import 'screens/authors_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/book_form_screen.dart';
import 'screens/books_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/catalog_screens.dart';
import 'screens/converter_screen.dart';
import 'screens/forbidden_screen.dart';
import 'screens/genre_form_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/loans_desk_screen.dart';
import 'screens/my_loans_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/publisher_form_screen.dart';
import 'screens/reader_form_screen.dart';
import 'screens/register_screen.dart';
import 'screens/result_screen.dart';
import 'state/auth_notifier.dart';

int? _idOf(GoRouterState state) => int.tryParse(state.pathParameters['id'] ?? '');

String? _need(AuthNotifier auth, bool allowed) => allowed ? null : '/forbidden';

GoRouter buildRouter(AuthNotifier auth) {
  return GoRouter(
    refreshListenable: auth,
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = auth.isAuthenticated;
      final target = state.matchedLocation;
      final isPublic = target == '/login' || target == '/register';

      if (!loggedIn && !isPublic) {
        return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
      }
      if (loggedIn && isPublic) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forbidden',
        builder: (context, state) => const ForbiddenScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/my-loans',
        redirect: (context, state) => _need(auth, auth.isReader),
        builder: (context, state) => const MyLoansScreen(),
      ),
      GoRoute(
        path: '/desk',
        redirect: (context, state) => _need(auth, auth.can(Operation.issueLoan)),
        builder: (context, state) => const LoansDeskScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        redirect: (context, state) => _need(auth, auth.can(Operation.manageUsers)),
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/stats',
        redirect: (context, state) => _need(auth, auth.can(Operation.viewStats)),
        builder: (context, state) => const AdminStatsScreen(),
      ),
      GoRoute(
        path: '/books',
        builder: (context, state) => BooksScreen(query: BookQuery.fromUri(state.uri)),
        routes: [
          GoRoute(
            path: 'new',
            redirect: (context, state) => _need(auth, auth.can(Operation.manageBooks)),
            builder: (context, state) => const BookFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => BookDetailScreen(id: _idOf(state)),
            routes: [
              GoRoute(
                path: 'edit',
                redirect: (context, state) => _need(auth, auth.can(Operation.manageBooks)),
                builder: (context, state) => BookFormScreen(id: _idOf(state)),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/authors',
        redirect: (context, state) => _need(auth, auth.can(Operation.manageCatalogs)),
        builder: (context, state) => AuthorsScreen(query: AuthorQuery.fromUri(state.uri)),
        routes: [
          GoRoute(path: 'new', builder: (context, state) => const AuthorFormScreen()),
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
        redirect: (context, state) => _need(auth, auth.can(Operation.manageCatalogs)),
        builder: (context, state) => GenresScreen(query: CatalogQuery.fromUri(state.uri)),
        routes: [
          GoRoute(path: 'new', builder: (context, state) => const GenreFormScreen()),
          GoRoute(path: ':id/edit', builder: (context, state) => GenreFormScreen(id: _idOf(state))),
        ],
      ),
      GoRoute(
        path: '/publishers',
        redirect: (context, state) => _need(auth, auth.can(Operation.manageCatalogs)),
        builder: (context, state) => PublishersScreen(query: CatalogQuery.fromUri(state.uri)),
        routes: [
          GoRoute(path: 'new', builder: (context, state) => const PublisherFormScreen()),
          GoRoute(path: ':id/edit', builder: (context, state) => PublisherFormScreen(id: _idOf(state))),
        ],
      ),
      GoRoute(
        path: '/readers',
        redirect: (context, state) => _need(auth, auth.can(Operation.manageReaders)),
        builder: (context, state) =>
            ReadersScreen(query: CatalogQuery.fromUri(state.uri, defaultSort: 'lastName')),
        routes: [
          GoRoute(path: 'new', builder: (context, state) => const ReaderFormScreen()),
          GoRoute(path: ':id/edit', builder: (context, state) => ReaderFormScreen(id: _idOf(state))),
        ],
      ),
      GoRoute(
        path: '/calculator',
        builder: (context, state) => const CalculatorScreen(),
        routes: [
          GoRoute(path: 'result', builder: (context, state) => const ResultScreen()),
        ],
      ),
      GoRoute(
        path: '/converter',
        builder: (context, state) => const ConverterScreen(),
        routes: [
          GoRoute(path: 'result', builder: (context, state) => const ResultScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => NotFoundScreen(location: state.uri.toString()),
  );
}
