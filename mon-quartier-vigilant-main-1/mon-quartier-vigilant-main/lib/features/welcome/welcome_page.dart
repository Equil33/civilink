import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/store/app_store.dart';

class WelcomePage extends StatelessWidget {
  final AppStore store;

  const WelcomePage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF08213D), Color(0xFF114A8E), Color(0xFF0A866D)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(),
                    const SizedBox(height: 20),
                    _HeroSection(store: store),
                    const SizedBox(height: 16),
                    _QuickActions(store: store),
                    const SizedBox(height: 18),
                    Text(
                      'Pourquoi utiliser Mon Quartier Vigilant ?',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    const _FeatureImageGrid(),
                    const SizedBox(height: 14),
                    _FastReportCard(store: store, scheme: scheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.shield_moon_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(
          'CiviLink',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final AppStore store;

  const _HeroSection({required this.store});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          const _NetworkHeroImage(),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.42),
                    Colors.black.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC83D),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'ACCUEIL GENERAL',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Mon Quartier Vigilant',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Une experience citoyenne moderne: signalement, suivi, et action locale dans une interface mobile intuitive.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC83D),
                        foregroundColor: const Color(0xFF1C1B14),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/connexion'),
                      icon: const Icon(Icons.lock_open_rounded),
                      label: const Text('Acceder a la connexion'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/explorer'),
                      icon: const Icon(Icons.travel_explore_rounded),
                      label: const Text('Explorer l application'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final AppStore store;

  const _QuickActions({required this.store});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final children = [
          _ActionTile(
            icon: Icons.login_rounded,
            label: 'Se connecter',
            onTap: () => Navigator.pushNamed(context, '/connexion'),
          ),
          _ActionTile(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Creer un compte',
            onTap: () => Navigator.pushNamed(context, '/inscription'),
          ),
          _ActionTile(
            icon: Icons.bolt_rounded,
            label: 'Signalement rapide',
            onTap: () => Navigator.pushNamed(context, '/signaler-rapide'),
          ),
        ];

        if (compact) {
          return Column(children: children);
        }

        return Row(
          children: children
              .map((child) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: child,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureImageGrid extends StatelessWidget {
  const _FeatureImageGrid();

  @override
  Widget build(BuildContext context) {
    final items = <({String title, String image, IconData icon})>[
      (
        title: 'Signalement en 2 minutes',
        image: 'assets/images/theme/feature_report.jpg',
        icon: Icons.timer_rounded,
      ),
      (
        title: 'Suivi des incidents',
        image: 'assets/images/theme/feature_tracking.jpg',
        icon: Icons.track_changes_rounded,
      ),
      (
        title: 'Securite urbaine collaborative',
        image: 'assets/images/theme/feature_collab.jpg',
        icon: Icons.groups_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 760 ? 1 : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 160,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _FeatureImageCard(item: item);
          },
        );
      },
    );
  }
}

class _FeatureImageCard extends StatelessWidget {
  final ({String title, String image, IconData icon}) item;

  const _FeatureImageCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _SafeAssetImage(path: item.image),
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(item.icon, color: Colors.white),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
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

class _FastReportCard extends StatelessWidget {
  final AppStore store;
  final ColorScheme scheme;

  const _FastReportCard({required this.store, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD86A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.flash_on_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Signalement rapide: acces limite (pas de suivi, profil, ni accueil).',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkHeroImage extends StatelessWidget {
  const _NetworkHeroImage();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: const _SafeAssetImage(
        path: 'assets/images/theme/hero_city.jpg',
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
          color: const Color(0xFF1A3554),
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_outlined, color: Colors.white70),
        );
      },
    );
  }
}
