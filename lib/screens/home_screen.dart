import 'package:flutter/material.dart';

import '../models/report_model.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import 'add_report_screen.dart';
import 'profile_screen.dart';
import 'report_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'All';

  List<ReportModel> _applyFilter(List<ReportModel> reports) {
    final uid = AuthService().getCurrentUser()?.uid;
    return reports.where((report) {
      if (_filter == 'Mine') return report.createdBy == uid;
      if (_filter == 'All') return true;
      return report.status == _filter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facility Reports'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddReportScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New report'),
      ),
      body: StreamBuilder<List<ReportModel>>(
        stream: ReportService().watchReports(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Could not load reports.\nPublish the Firestore rules, then try again.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data!;
          final visible = _applyFilter(all);
          final openCount = all.where((r) => r.status == 'Open').length;
          final doingCount = all.where((r) => r.status == 'In progress').length;
          final doneCount = all.where((r) => r.status == 'Resolved').length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    _CountCard(label: 'Open', count: openCount),
                    const SizedBox(width: 8),
                    _CountCard(label: 'In progress', count: doingCount),
                    const SizedBox(width: 8),
                    _CountCard(label: 'Resolved', count: doneCount),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    for (final option in [
                      'All',
                      'Open',
                      'In progress',
                      'Resolved',
                      'Mine',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(option),
                          selected: _filter == option,
                          onSelected: (_) => setState(() => _filter = option),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? Center(
                        child: Text(
                          all.isEmpty
                              ? 'No facility issues yet.\nTap New report to add one.'
                              : 'No reports in this filter.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final report = visible[index];
                          return Card(
                            child: ListTile(
                              leading: _ReportThumb(report: report),
                              title: Text(report.title),
                              subtitle: Text(
                                [
                                  report.area.isEmpty
                                      ? report.assetType
                                      : '${report.assetType} • ${report.area}',
                                  '${report.priority} priority • ${report.status}',
                                ].join('\n'),
                              ),
                              isThreeLine: true,
                              trailing: Icon(
                                report.priority == 'High'
                                    ? Icons.priority_high
                                    : Icons.chevron_right,
                                color: report.priority == 'High'
                                    ? Colors.red
                                    : null,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ReportDetailScreen(reportId: report.id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final String label;
  final int count;

  const _CountCard({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportThumb extends StatelessWidget {
  final ReportModel report;

  const _ReportThumb({required this.report});

  @override
  Widget build(BuildContext context) {
    if (report.imageUrl.isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.teal.shade50,
        child: const Icon(Icons.apartment),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        report.imageUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const CircleAvatar(
          child: Icon(Icons.broken_image),
        ),
      ),
    );
  }
}
