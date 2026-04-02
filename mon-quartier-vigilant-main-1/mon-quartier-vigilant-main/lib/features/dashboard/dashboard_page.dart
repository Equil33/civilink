import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/report_model.dart';
import '../../core/store/app_store.dart';

class DashboardPage extends StatefulWidget {
  final AppStore store;

  const DashboardPage({super.key, required this.store});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Map<String, String> selectedAction = {};

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    const deepBlue = Color(0xFF1D4F94);
    const accent = Color(0xFFF59E0B);
    const bg = Color(0xFFF4F6FA);

    final total = store.total == 0 ? 1 : store.total;
    final waiting = store.newCount;
    final inProgress = store.inProgressCount;
    final resolved = store.resolvedCount;
    final resolveRate = ((resolved / total) * 100).round();

    final quartierKeys = [
      'Centre-ville',
      'Les Fleurs',
      'Bellevue',
      'La Gare',
      'Nouveaute',
    ];
    final quartierCounts = {
      for (final q in quartierKeys)
        q: store.reports.where((r) => r.quartier == q).length,
    };
    final maxBar = quartierCounts.values.fold<int>(1, (int a, int b) => b > a ? b : a);

    final catCount = <String, int>{for (final k in categories.keys) k: 0};
    for (final r in store.reports) {
      catCount[r.category] = (catCount[r.category] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Retour',
                        onPressed: () => _goBack(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: deepBlue,
                        ),
                      ),
                      const Icon(Icons.shield_outlined, color: deepBlue),
                      const SizedBox(width: 8),
                      const Text(
                        'CiviLink',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(width: 24),
                        _navItem(context, 'Accueil', '/accueil', false),
                        _navItem(context, 'Signaler', '/signaler', false),
                        _navItem(context, 'Suivi', '/signalements', false),
                        _navItem(context, 'Statut', '/tableau-de-bord', true),
                      ],
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/signaler'),
                        icon: const Icon(Icons.add_box_outlined, size: 18),
                        label: Text(
                          isMobile ? 'Signaler' : 'Nouveau signalement',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 34, 24, 54),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tableau de bord',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Gestion municipale des signalements citoyens',
                        style: TextStyle(
                          fontSize: 27,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 18),
                      GridView.count(
                        crossAxisCount: isMobile ? 2 : 4,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.9,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _kpiCard(
                            'Total signalements',
                            '$total',
                            '+3 cette semaine',
                            const Color(0xFF16A34A),
                          ),
                          _kpiCard(
                            'En attente',
                            '$waiting',
                            '${((waiting / total) * 100).round()}% du total',
                            deepBlue,
                          ),
                          _kpiCard(
                            'En cours',
                            '$inProgress',
                            '${((inProgress / total) * 100).round()}% du total',
                            const Color(0xFFD97706),
                          ),
                          _kpiCard(
                            'Resolus',
                            '$resolved',
                            'Taux : $resolveRate%',
                            const Color(0xFF16A34A),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _panel(
                        title: 'Signalements par quartier',
                        child: SizedBox(
                          height: 220,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: quartierKeys.map((q) {
                              final v = quartierCounts[q] ?? 0;
                              final h = 30 + (v / maxBar) * 120;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: h,
                                        decoration: BoxDecoration(
                                          color: Color.lerp(
                                            const Color(0xFF1D4F94),
                                            const Color(0xFFAEC2DF),
                                            quartierKeys.indexOf(q) /
                                                (quartierKeys.length - 1),
                                          ),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(8),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        q,
                                        style: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _panel(
                        title: 'Repartition par categorie',
                        child: Wrap(
                          spacing: 14,
                          runSpacing: 10,
                          children: [
                            _legend(
                              'Routes',
                              _percent(catCount['route'] ?? 0, total),
                              const Color(0xFF1D4F94),
                            ),
                            _legend(
                              'Eclairage',
                              _percent(catCount['eclairage'] ?? 0, total),
                              const Color(0xFFF59E0B),
                            ),
                            _legend(
                              'Dechets',
                              _percent(catCount['dechets'] ?? 0, total),
                              const Color(0xFFDC2626),
                            ),
                            _legend(
                              'Espaces verts',
                              _percent(catCount['autre'] ?? 0, total),
                              const Color(0xFF16A34A),
                            ),
                            _legend(
                              'Autres',
                              _percent((catCount['inondation'] ?? 0), total),
                              const Color(0xFF0EA5E9),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _panel(
                        title: 'Gestion des signalements',
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingTextStyle: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            dataTextStyle: const TextStyle(fontSize: 16),
                            columns: const [
                              DataColumn(label: Text('SIGNALEMENT')),
                              DataColumn(label: Text('CATEGORIE')),
                              DataColumn(label: Text('QUARTIER')),
                              DataColumn(label: Text('DATE')),
                              DataColumn(label: Text('STATUT')),
                              DataColumn(label: Text('ACTION')),
                            ],
                            rows: store.reports
                                .take(8)
                                .map((r) => _row(r))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _percent(int n, int total) => '${((n / total) * 100).round()}%';

  DataRow _row(ReportModel r) {
    final statusColor = switch (r.status) {
      'nouveau' => const Color(0xFF2563EB),
      'en_cours' => const Color(0xFFD97706),
      _ => const Color(0xFF16A34A),
    };
    final statusBg = switch (r.status) {
      'nouveau' => const Color(0xFFDBEAFE),
      'en_cours' => const Color(0xFFFDE8CF),
      _ => const Color(0xFFDCFCE7),
    };
    final label = switch (r.status) {
      'nouveau' => 'Nouveau',
      'en_cours' => 'En cours',
      _ => 'Resolu',
    };
    final selected = selectedAction[r.id] ?? label;
    return DataRow(
      cells: [
        DataCell(Text(r.title)),
        DataCell(Text(categories[r.category] ?? r.category)),
        DataCell(Text(r.quartier)),
        DataCell(Text(r.date)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 130,
            child: DropdownButtonFormField<String>(
              initialValue: selected,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Nouveau', child: Text('Nouveau')),
                DropdownMenuItem(value: 'En cours', child: Text('En cours')),
                DropdownMenuItem(value: 'Resolu', child: Text('Resolu')),
              ],
              onChanged: (v) async {
                if (v == null) return;
                setState(() => selectedAction[r.id] = v);
                final newStatus = switch (v) {
                  'Nouveau' => 'nouveau',
                  'En cours' => 'en_cours',
                  _ => 'resolu',
                };
                await widget.store.updateStatus(r.id, newStatus);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _kpiCard(String title, String value, String hint, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5DEE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(hint, style: TextStyle(color: valueColor, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _legend(String label, String percent, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text('$label ($percent)', style: const TextStyle(fontSize: 19)),
      ],
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5DEE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 39,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    String label,
    String route,
    bool active,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton.icon(
        onPressed: () => Navigator.pushNamed(context, route),
        icon: Icon(
          active ? Icons.grid_view_outlined : Icons.circle_outlined,
          size: 15,
        ),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: active
              ? const Color(0xFF1D4F94)
              : const Color(0xFF6B7280),
          backgroundColor: active
              ? const Color(0xFFE8F0FC)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
      return;
    }
    if (ModalRoute.of(context)?.settings.name != '/accueil') {
      nav.pushNamed('/accueil');
    }
  }
}
