import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/breakpoints.dart';
import '../data/catalog_cache.dart';
import '../models/role.dart';
import '../state/auth_notifier.dart';
import '../state/connection_notifier.dart';

class _Dest {
  final String location;
  final String label;
  final IconData icon;
  final bool Function(AuthNotifier auth) visible;

  const _Dest(this.location, this.label, this.icon, this.visible);
}

const _destinations = <_Dest>[
  _Dest('/', 'Главная', Icons.home_outlined, _always),
  _Dest('/books', 'Каталог', Icons.menu_book_outlined, _always),
  _Dest('/my-loans', 'Мои выдачи', Icons.bookmark_outline, _reader),
  _Dest('/desk', 'Стол выдачи', Icons.point_of_sale_outlined, _librarian),
  _Dest('/authors', 'Авторы', Icons.people_alt_outlined, _librarian),
  _Dest('/genres', 'Жанры', Icons.category_outlined, _librarian),
  _Dest('/publishers', 'Издательства', Icons.business_outlined, _librarian),
  _Dest('/readers', 'Читатели', Icons.badge_outlined, _librarian),
  _Dest('/admin/users', 'Пользователи', Icons.manage_accounts_outlined, _admin),
  _Dest('/admin/stats', 'Статистика', Icons.insights_outlined, _admin),
  _Dest('/calculator', 'Калькулятор', Icons.calculate_outlined, _always),
  _Dest('/converter', 'Конвертер', Icons.currency_exchange, _always),
];

bool _always(AuthNotifier auth) => true;
bool _reader(AuthNotifier auth) => auth.can(Operation.viewOwnLoans);
bool _librarian(AuthNotifier auth) =>
    auth.can(Operation.manageCatalogs) || auth.can(Operation.issueLoan);
bool _admin(AuthNotifier auth) =>
    auth.can(Operation.manageUsers) || auth.can(Operation.viewStats);

class AdaptiveShell extends StatelessWidget {
  final Widget child;

  const AdaptiveShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    if (!auth.isAuthenticated) return child;

    final dests = _destinations.where((d) => d.visible(auth)).toList();
    final location = GoRouterState.of(context).uri.path;
    final selected = _selectedIndex(dests, location);
    final phone = useBottomNav(context);
    final extended = useExtendedRail(context);

    final body = Column(
      children: [
        const OfflineBanner(),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: contentMaxWidth),
              child: child,
            ),
          ),
        ),
      ],
    );

    if (phone) {
      final overflow = dests.length > 4;
      final bar = overflow ? dests.take(3).toList() : dests;
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: overflow && selected >= 3
              ? 3
              : selected.clamp(0, bar.length - 1),
          onDestinationSelected: (index) {
            if (overflow && index == 3) {
              _showMore(context, dests.skip(3).toList());
              return;
            }
            context.go(bar[index].location);
          },
          destinations: [
            for (final dest in bar)
              NavigationDestination(
                icon: Icon(dest.icon),
                label: dest.label,
                tooltip: dest.label,
              ),
            if (overflow)
              const NavigationDestination(
                icon: Icon(Icons.more_horiz),
                label: 'Ещё',
                tooltip: 'Ещё',
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      extended: extended,
                      selectedIndex: selected.clamp(0, dests.length - 1),
                      onDestinationSelected: (index) =>
                          context.go(dests[index].location),
                      labelType: extended
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      destinations: [
                        for (final dest in dests)
                          NavigationRailDestination(
                            icon: Tooltip(
                              message: dest.label,
                              child: Icon(dest.icon),
                            ),
                            label: Text(dest.label),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }

  int _selectedIndex(List<_Dest> dests, String location) {
    var best = 0;
    var bestLen = -1;
    for (var i = 0; i < dests.length; i++) {
      final path = dests[i].location;
      final match =
          location == path || (path != '/' && location.startsWith('$path/'));
      if (match && path.length > bestLen) {
        best = i;
        bestLen = path.length;
      }
    }
    return best;
  }

  Future<void> _showMore(BuildContext context, List<_Dest> extra) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final dest in extra)
                ListTile(
                  leading: Icon(dest.icon),
                  title: Text(dest.label),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(dest.location);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connection = context.watch<ConnectionNotifier>();
    if (connection.online) return const SizedBox.shrink();
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.wifi_off,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Нет связи с сервером. Списки пустыми не оставляем — нажмите «Повторить».',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await connection.check();
                if (context.mounted) {
                  await context.read<CatalogCache>().ensureLoaded();
                }
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
