import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/store/app_store.dart';
import '../../core/widgets/app_shell.dart';

class HomePage extends StatefulWidget {
  final AppStore store;

  const HomePage({super.key, required this.store});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Rafraîchir les signalements toutes les 20 secondes pour la page d'accueil
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      widget.store.refreshReports();
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      store: widget.store,
      title: 'Accueil',
      currentIndex: 0,
      body: RefreshIndicator(
        onRefresh: () => widget.store.refreshReports(),
        child: ListView(
          padding: context.pagePadding,
          children: [
            _HeroCard(store: widget.store),
            const SizedBox(height: 16),
            _StatsRow(store: widget.store),
            const SizedBox(height: 20),
            Text('Categories frequentes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _CategoryGrid(),
            const SizedBox(height: 20),
            Text('Derniers signalements', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (widget.store.reports.isEmpty)
              const _EmptyReportsCard()
            else
              ...widget.store.reports.take(3).map((report) => _RecentReportTile(report: report)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/signalements'),
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('Voir tous les signalements'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final AppStore store;

  const _HeroCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: const _SafeAssetImage(
              path: 'assets/images/theme/hero_city.jpg',
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    const Color(0xFF06213D).withValues(alpha: 0.58),
                    const Color(0xFF0B7E66).withValues(alpha: 0.28),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Une ville plus sure commence ici',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prenez une photo, localisez le probleme et envoyez votre signalement en moins de 2 minutes.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.95)),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC83D),
                    foregroundColor: const Color(0xFF1F1B10),
                  ),
                  onPressed: () {
                    final target = store.isMember ? '/signaler' : '/signaler-rapide';
                    Navigator.pushNamed(context, target);
                  },
                  icon: const Icon(Icons.add_location_alt_rounded),
                  label: const Text('Nouveau signalement'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AppStore store;

  const _StatsRow({required this.store});

  @override
  Widget build(BuildContext context) {
    final stats = <({String title, String value, IconData icon, Color color})>[
      (title: 'Total', value: '${store.total}', icon: Icons.assessment_rounded, color: const Color(0xFF0072B2)),
      (title: 'Nouveaux', value: '${store.newCount}', icon: Icons.fiber_new_rounded, color: const Color(0xFFE69F00)),
      (title: 'Resolus', value: '${store.resolvedCount}', icon: Icons.task_alt_rounded, color: const Color(0xFFCC79A7)),
    ];

    return Row(
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _StatCard(stat: stats[i], context: context),
          ),
        ]
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final ({String title, String value, IconData icon, Color color}) stat;
  final BuildContext context;

  const _StatCard({required this.stat, required this.context});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: stat.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(stat.icon, color: stat.color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              stat.value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.title,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entries = categories.entries.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 480 ? 2 : 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 116,
          ),
          itemBuilder: (context, index) {
            final item = entries[index];
            final image = categoryImageUrls[item.key] ??
                'assets/images/theme/other_urban.jpg';
            return _CategoryImageCard(title: item.value, imageUrl: image);
          },
        );
      },
    );
  }
}

class _CategoryImageCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const _CategoryImageCard({required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _SafeAssetImage(path: imageUrl),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.65), Colors.transparent],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentReportTile extends StatelessWidget {
  final dynamic report;

  const _RecentReportTile({required this.report});

  @override
  Widget build(BuildContext context) {
    final status = switch (report.status) {
      'nouveau' => (label: 'Nouveau', color: const Color(0xFF0072B2)),
      'en_cours' => (label: 'En cours', color: const Color(0xFFE69F00)),
      'resolu' => (label: 'Resolu', color: const Color(0xFFCC79A7)),
      _ => (label: 'Inconnu', color: Colors.grey),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Text(report.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(report.address, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            status.label,
            style: TextStyle(fontWeight: FontWeight.w700, color: status.color),
          ),
        ),
      ),
    );
  }
}

class _EmptyReportsCard extends StatelessWidget {
  const _EmptyReportsCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.inbox_outlined),
            SizedBox(width: 10),
            Expanded(child: Text('Aucun signalement pour le moment.')),
          ],
        ),
      ),
    );
  }
}

class _SafeAssetImage extends StatelessWidget {
  final String path;

  const _SafeAssetImage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, error, stackTrace) {
        return Container(
          color: const Color(0xFF203754),
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_outlined, color: Colors.white70),
        );
      },
    );
  }
}
