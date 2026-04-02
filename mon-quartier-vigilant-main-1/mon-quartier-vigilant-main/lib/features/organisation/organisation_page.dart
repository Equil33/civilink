import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/report_model.dart';
import '../../core/store/app_store.dart';

class OrganisationPage extends StatefulWidget {
  final AppStore store;

  const OrganisationPage({super.key, required this.store});

  @override
  State<OrganisationPage> createState() => _OrganisationPageState();
}

class _OrganisationPageState extends State<OrganisationPage>
    with SingleTickerProviderStateMixin {
  String org = 'Mairie';
  String orgName = '';
  String search = '';
  String statusFilter = 'all';
  late final AnimationController _alertController;

  final Map<String, IconData> orgIcons = const {
    'Hopital': Icons.local_hospital_outlined,
    'Clinique': Icons.local_hospital_outlined,
    'Mairie': Icons.account_balance_outlined,
    'Police': Icons.shield_outlined,
    'Pompiers': Icons.local_fire_department_outlined,
    'Gendarmerie': Icons.security_outlined,
    'Lavoirie': Icons.delete_sweep_outlined,
  };

  @override
  void initState() {
    super.initState();
    _alertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    orgName = widget.store.userName;
    final fromSession = normalizeOrganisationName(widget.store.userName);
    if (organisationIncidentScopes.containsKey(fromSession)) {
      org = fromSession;
      return;
    }

    final inferredType = inferOrganisationTypeFromName(widget.store.userName);
    final inferredLabel = labelForOrganisationType(inferredType);
    if (organisationIncidentScopes.containsKey(inferredLabel)) {
      org = inferredLabel;
    }
  }

  final Map<String, Color> orgColors = {
    'Hopital': const Color.fromARGB(255, 38, 162, 220),
    'Clinique': const Color.fromARGB(255, 68, 193, 239),
    'Mairie': const Color(0xFF1D4F94),
    'Police': const Color(0xFF4B5563),
    'Pompiers': const Color(0xFFFDB913),
    'Gendarmerie': const Color(0xFF2563EB),
    'Lavoirie': const Color.fromARGB(255, 43, 14, 90),
  };

  @override
  void dispose() {
    _alertController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;
    const deepBlue = Color(0xFF1D4F94);
    const bg = Color(0xFFF2F5FA);

    final covered = organisationIncidentScopes[org] ?? const <String>[];
    final visible = widget.store.reports.where((r) {
      final matchOrg = covered.contains(r.category);
      final matchSearch =
          search.isEmpty ||
          r.title.toLowerCase().contains(search.toLowerCase()) ||
          r.quartier.toLowerCase().contains(search.toLowerCase());
      final matchStatus = statusFilter == 'all' || r.status == statusFilter;
      return matchOrg && matchSearch && matchStatus;
    }).toList();

    final total = visible.length;
    final newCount = visible.where((r) => r.status == 'nouveau').length;
    final inProgress = visible.where((r) => r.status == 'en_cours').length;
    final resolved = visible.where((r) => r.status == 'resolu').length;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: deepBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1360),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Retour',
                        onPressed: () => _goBack(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          orgIcons[org] ?? Icons.business_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orgName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Type : $org',
                            style: const TextStyle(color: Color(0xFFC7D7EF)),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1360),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: organisationIncidentScopes.keys.map((orgName) {
                        final isSelected = orgName == org;
                        final color = orgColors[orgName] ?? const Color(0xFF64748B);
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: FilterChip(
                            selected: isSelected,
                            onSelected: (_) => setState(() => org = orgName),
                            label: Text(orgName),
                            avatar: Icon(
                              orgIcons[orgName] ?? Icons.business_outlined,
                              size: 18,
                            ),
                            backgroundColor: color.withValues(alpha: 0.1),
                            selectedColor: color.withValues(alpha: 0.25),
                            labelStyle: TextStyle(
                              color: color,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: color,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: bg,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1360),
                  child: Column(
                    children: [
                      GridView.count(
                        crossAxisCount: isMobile ? 2 : 4,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 2.35,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _kpi(
                            Icons.notifications_outlined,
                            '$total',
                            'Total recus',
                            const Color(0xFF1D4F94),
                          ),
                          _kpi(
                            Icons.warning_amber_outlined,
                            '$newCount',
                            'Nouveaux',
                            const Color(0xFF1D4F94),
                          ),
                          _kpi(
                            Icons.timelapse_outlined,
                            '$inProgress',
                            'En cours',
                            const Color(0xFFD97706),
                          ),
                          _kpi(
                            Icons.check_circle_outline,
                            '$resolved',
                            'Resolus',
                            const Color(0xFF16A34A),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      FadeTransition(
                        opacity: Tween<double>(
                          begin: 0.35,
                          end: 1,
                        ).animate(_alertController),
                        child: _panel(
                          child: Row(
                            children: const [
                              Icon(
                                Icons.notification_important_rounded,
                                color: Color(0xFFDC2626),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Alerte active: surveillez les nouveaux incidents en temps reel.',
                                  style: TextStyle(
                                    color: Color(0xFF991B1B),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _panel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Categories couvertes par $org :',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: covered
                                  .map(
                                    (c) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE7ECF3),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        categories[c] ?? c,
                                        style: const TextStyle(
                                          color: Color(0xFF345B8A),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Rechercher un signalement...',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD5DEE8),
                                  ),
                                ),
                              ),
                              onChanged: (v) => setState(() => search = v),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: isMobile ? 170 : 180,
                            child: DropdownButtonFormField<String>(
                              initialValue: statusFilter,
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text('Tous les statuts'),
                                ),
                                DropdownMenuItem(
                                  value: 'nouveau',
                                  child: Text('Nouveaux'),
                                ),
                                DropdownMenuItem(
                                  value: 'en_cours',
                                  child: Text('En cours'),
                                ),
                                DropdownMenuItem(
                                  value: 'resolu',
                                  child: Text('Resolus'),
                                ),
                              ],
                              onChanged: (v) => setState(
                                () => statusFilter = v ?? statusFilter,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...visible.map((r) => _item(r)),
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

  Widget _kpi(IconData icon, String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5DEE8)),
      ),
      child: Row(
        children: [
          Icon(icon, color: valueColor),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
              Text(label, style: const TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5DEE8)),
      ),
      child: child,
    );
  }

  Widget _item(ReportModel r) {
    final isHighPriority =
        r.category == 'route' ||
        r.category == 'dechets' ||
        (org == 'Pompiers' && r.status == 'en_cours');
    final priorityColor = (org == 'Pompiers' && r.status == 'en_cours')
        ? const Color(0xFFDC2626)
        : (isHighPriority ? const Color(0xFFD97706) : const Color(0xFF1D4F94));
    final priorityLabel = (org == 'Pompiers' && r.status == 'en_cours')
        ? 'Urgente'
        : (isHighPriority ? 'Haute' : 'Moyenne');
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
    final statusLabel = switch (r.status) {
      'nouveau' => 'Nouveau',
      'en_cours' => 'En cours',
      _ => 'Resolu',
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: orgColors[org] ?? const Color(0xFFD5DEE8),
          width: 2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (orgColors[org] ?? const Color(0xFF1D4F94)).withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 65,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (orgColors[org] ?? const Color(0xFF1D4F94)).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          priorityLabel,
                          style: TextStyle(
                            color: orgColors[org] ?? const Color(0xFF1D4F94),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    r.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${r.quartier}  •  ${r.date}   ${categories[r.category] ?? r.category}',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.expand_more),
              onSelected: (v) => widget.store.updateStatus(r.id, v),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'nouveau', child: Text('Nouveau')),
                PopupMenuItem(value: 'en_cours', child: Text('En cours')),
                PopupMenuItem(value: 'resolu', child: Text('Resolu')),
              ],
            ),
          ],
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

