import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/models/report_model.dart';
import '../../core/store/app_store.dart';
import '../../core/widgets/app_shell.dart';

typedef ReportStatusMeta = ({String label, Color color, IconData icon});

class ReportsPage extends StatefulWidget {
  final AppStore store;

  const ReportsPage({super.key, required this.store});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late Timer _refreshTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Rafraîchir les signalements toutes les 15 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (!_isRefreshing) {
        _isRefreshing = true;
        await widget.store.refreshReports();
        _isRefreshing = false;
      }
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
      title: 'Suivi des signalements',
      currentIndex: 1,
      body: RefreshIndicator(
        onRefresh: () => widget.store.refreshReports(),
        child: ListView(
          padding: context.pagePadding,
          children: [
            if (_isRefreshing)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Synchronisation...',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            if (widget.store.unseenResolutionPhotoCount > 0)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Nouvelle preuve de resolution disponible (${widget.store.unseenResolutionPhotoCount}).',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.store.reports.isEmpty)
              const _EmptyState()
            else
              ...widget.store.reports.map((report) => _ReportCard(report: report, store: widget.store)),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final AppStore store;

  const _ReportCard({required this.report, required this.store});

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta(report.status);
    final hasPhotos = report.resolutionPhotos.isNotEmpty;
    final hasNewPhotos = hasPhotos && store.hasUnseenResolutionPhotos(report);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(meta.icon, color: meta.color, size: 18),
                const SizedBox(width: 6),
                Text(
                  meta.label,
                  style: TextStyle(color: meta.color, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(report.date, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(report.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(report.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(report.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.thumb_up_alt_outlined, size: 16),
                const SizedBox(width: 4),
                Text('${report.votes}'),
              ],
            ),
            if (hasPhotos) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.photo_library_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    hasNewPhotos ? 'Preuve de resolution (nouveau)' : 'Preuve de resolution',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      await showDialog<void>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Photos de resolution'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: report.resolutionPhotos.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final url = store.resolveMediaUrl(report.resolutionPhotos[index]);
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const SizedBox(
                                        height: 140,
                                        child: Center(child: Text('Image indisponible')),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Fermer'),
                              ),
                            ],
                          );
                        },
                      );
                      await store.markResolutionPhotosSeen(report);
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Voir photo'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  ReportStatusMeta _statusMeta(String status) {
    return switch (status) {
      'nouveau' => (label: 'Nouveau', color: Color(0xFF0072B2), icon: Icons.fiber_new_rounded),
      'en_cours' => (label: 'En cours', color: Color(0xFFE69F00), icon: Icons.autorenew_rounded),
      'resolu' => (label: 'Resolu', color: Color(0xFFCC79A7), icon: Icons.task_alt_rounded),
      _ => (label: 'Inconnu', color: Colors.grey, icon: Icons.help_outline_rounded),
    };
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.inbox_outlined),
            SizedBox(width: 10),
            Expanded(child: Text('Aucun signalement trouve.')),
          ],
        ),
      ),
    );
  }
}
