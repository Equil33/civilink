import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/store/app_store.dart';

class ExplorePage extends StatelessWidget {
  final AppStore store;

  const ExplorePage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final total = store.total;
    final resolved = store.resolvedCount;
    final inProgress = store.inProgressCount;
    final resolvedRate = total == 0 ? 0 : ((resolved / total) * 100).round();

    final highlights = <({String title, String value, IconData icon})>[
      (title: 'Inscrits actifs', value: '12 480', icon: Icons.groups_rounded),
      (title: 'Signalements resolus', value: '$resolved', icon: Icons.task_alt_rounded),
      (title: 'Taux de resolution', value: '$resolvedRate%', icon: Icons.donut_large_rounded),
      (title: 'Dossiers en cours', value: '$inProgress', icon: Icons.autorenew_rounded),
    ];

    final steps = <({String title, String detail, String image, IconData icon})>[
      (
        title: '1. Signaler un probleme',
        detail: 'Vous ajoutez photo, categorie, localisation GPS et description.',
        image: 'assets/images/theme/feature_report.jpg',
        icon: Icons.add_location_alt_rounded
      ),
      (
        title: '2. Verification automatique',
        detail: 'Le signalement est classe, priorise et transmis a l equipe competente.',
        image: 'assets/images/theme/feature_tracking.jpg',
        icon: Icons.rule_rounded
      ),
      (
        title: '3. Suivi en temps reel',
        detail: 'Vous suivez le statut: nouveau, en cours, puis resolu.',
        image: 'assets/images/theme/hero_city.jpg',
        icon: Icons.timeline_rounded
      ),
      (
        title: '4. Resolution collaborative',
        detail: 'La communaute et les services urbains finalisent l intervention.',
        image: 'assets/images/theme/feature_collab.jpg',
        icon: Icons.handshake_rounded
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer l application'),
      ),
      body: ListView(
        padding: context.pagePadding,
        children: [
          _IntroBanner(),
          const SizedBox(height: 16),
          Text('Indicateurs cles', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _HighlightsGrid(items: highlights),
          const SizedBox(height: 18),
          Text('Fonctionnement en 4 etapes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ...steps.map((step) => _StepCard(step: step)),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/connexion'),
            icon: const Icon(Icons.login_rounded),
            label: const Text('Commencer maintenant'),
          ),
        ],
      ),
    );
  }
}

class _IntroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Image.asset(
              'assets/images/theme/hero_city.jpg',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [scheme.primary.withValues(alpha: 0.72), Colors.black.withValues(alpha: 0.14)],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Comment l application fonctionne',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  'Un parcours simple pour signaler, suivre et voir les resolutions.',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightsGrid extends StatelessWidget {
  final List<({String title, String value, IconData icon})> items;

  const _HighlightsGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 700 ? 2 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 112,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon),
                    const SizedBox(height: 8),
                    Text(item.value, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(item.title, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StepCard extends StatelessWidget {
  final ({String title, String detail, String image, IconData icon}) step;

  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Image.asset(
                step.image,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(step.icon),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 5),
                      Text(step.detail, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
