import 'package:flutter/material.dart';

import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportDetailScreen extends StatelessWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  Future<void> _advance(BuildContext context, ReportModel report) async {
    try {
      await ReportService().updateStatus(report.id, report.nextStatus);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status set to ${report.nextStatus}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ReportModel?>(
      stream: ReportService().watchReport(reportId),
      builder: (context, snapshot) {
        final report = snapshot.data;
        return Scaffold(
          appBar: AppBar(title: const Text('Report detail')),
          body: report == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      report.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text(report.status)),
                        Chip(label: Text('${report.priority} priority')),
                        Chip(label: Text(report.assetType)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (report.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          report.imageUrl,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Text('Photo could not load'),
                        ),
                      )
                    else
                      const Text('No photo attached'),
                    const SizedBox(height: 16),
                    const Text(
                      'Where',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      report.area.isEmpty
                          ? 'Area not named'
                          : report.area,
                    ),
                    Text(
                      report.location.isEmpty
                          ? 'GPS not recorded'
                          : report.location,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      report.description.isEmpty
                          ? 'No extra detail'
                          : report.description,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Reported by',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      report.createdByEmail.isEmpty
                          ? report.createdBy
                          : report.createdByEmail,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      report.status == 'Open'
                          ? 'Next step: a staff member starts work on this asset.'
                          : report.status == 'In progress'
                              ? 'Work has started. Mark resolved when the asset is fixed.'
                              : 'This issue is closed. Reopen it if the problem comes back.',
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => _advance(context, report),
                      child: Text(report.nextActionLabel),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
