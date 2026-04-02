import 'package:flutter/material.dart';

import '../store/app_store.dart';

class AppShell extends StatelessWidget {
  final AppStore store;
  final String title;
  final Widget body;
  final int currentIndex;
  final List<Widget>? actions;

  const AppShell({
    super.key,
    required this.store,
    required this.title,
    required this.body,
    required this.currentIndex,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.shield_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onDestinationTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt_rounded),
            label: 'Suivi',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_location_alt_outlined),
            selectedIcon: Icon(Icons.add_location_alt_rounded),
            label: 'Signaler',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _onDestinationTap(BuildContext context, int index) {
    final routes = ['/accueil', '/signalements', '/signaler', '/profil'];
    final targetRoute = routes[index];

    if (!store.isMember) {
      Navigator.pushNamed(context, '/connexion');
      return;
    }

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == targetRoute) return;

    Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
  }
}
