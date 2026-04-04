import 'package:flutter/material.dart';

import '../../core/store/app_store.dart';
import '../../core/widgets/app_shell.dart';

class AdminPage extends StatelessWidget {
  final AppStore store;

  const AdminPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final quickReporterIds =
        store.reports
            .where((r) => r.reporterType == 'quick_guest')
            .map((r) => r.reporterId)
            .toSet()
            .toList()
          ..sort();

    return AppShell(
      store: store,
      title: 'Admin',
      currentIndex: 3,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Signalements'),
                  trailing: Text(store.total.toString()),
                ),
                ListTile(
                  title: const Text('Nouveaux'),
                  trailing: Text(store.newCount.toString()),
                ),
                ListTile(
                  title: const Text('En cours'),
                  trailing: Text(store.inProgressCount.toString()),
                ),
                ListTile(
                  title: const Text('Resolus'),
                  trailing: Text(store.resolvedCount.toString()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Identifiants signalement rapide',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (quickReporterIds.isEmpty)
                    const Text('Aucun signalement rapide pour le moment.')
                  else
                    ...quickReporterIds.map((id) {
                      final banned = store.isGuestReporterIdBanned(id);
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(id),
                        subtitle: Text(banned ? 'Etat: banni' : 'Etat: actif'),
                        trailing: FilledButton.tonal(
                          onPressed: () async {
                            if (banned) {
                              await store.unbanGuestReporter(id);
                            } else {
                              await store.banGuestReporter(id);
                            }
                          },
                          child: Text(banned ? 'Debannir' : 'Bannir'),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
