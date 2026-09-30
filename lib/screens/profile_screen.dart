import 'package:flutter/material.dart';

import '../models/report_model.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().getCurrentUser();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: StreamBuilder<List<ReportModel>>(
        stream: ReportService().watchReports(),
        builder: (context, snapshot) {
          final mine = (snapshot.data ?? [])
              .where((report) => report.createdBy == user?.uid)
              .toList();
          final open = mine.where((r) => r.status == 'Open').length;
          final doing = mine.where((r) => r.status == 'In progress').length;
          final done = mine.where((r) => r.status == 'Resolved').length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const ListTile(
                leading: Icon(Icons.apartment),
                title: Text('Smart Facilities'),
                subtitle: Text('ICT205 Assessment 3'),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Signed in as'),
                subtitle: Text(user?.email ?? 'Unknown user'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: Text('${mine.length} reports submitted by you'),
                subtitle: Text(
                  'Open $open  •  In progress $doing  •  Resolved $done',
                ),
              ),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('How the workflow works'),
                subtitle: Text(
                  'New reports start as Open. Staff tap Start work, then Mark as resolved when the asset is fixed.',
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  await AuthService().logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          );
        },
      ),
    );
  }
}
