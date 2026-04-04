import 'package:flutter/material.dart';

import '../../../core/models/report_model.dart';
import '../../../core/store/app_store.dart';

class ReportCard extends StatelessWidget {
  final AppStore store;
  final ReportModel report;

  const ReportCard({
    super.key,
    required this.store,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(report.title),
        subtitle: Text('${report.quartier} - ${report.address}\n${report.status} - ${report.date}'),
        isThreeLine: true,
        trailing: TextButton.icon(
          onPressed: () => store.vote(report.id),
          icon: const Icon(Icons.thumb_up_alt_outlined),
          label: Text('${report.votes}'),
        ),
      ),
    );
  }
}
