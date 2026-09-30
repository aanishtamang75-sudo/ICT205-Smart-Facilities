import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/report_model.dart';

class ReportService {
  final _reports = FirebaseFirestore.instance.collection('reports');

  Stream<List<ReportModel>> watchReports() {
    return _reports.orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) {
        final items = snapshot.docs
            .map((doc) => ReportModel.fromMap(doc.id, doc.data()))
            .toList();
        items.sort((a, b) {
          final byStatus = a.workflowRank.compareTo(b.workflowRank);
          if (byStatus != 0) return byStatus;
          final byPriority = a.priorityRank.compareTo(b.priorityRank);
          if (byPriority != 0) return byPriority;
          final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
          final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
          return bTime.compareTo(aTime);
        });
        return items;
      },
    );
  }

  Stream<ReportModel?> watchReport(String id) {
    return _reports.doc(id).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return ReportModel.fromMap(doc.id, data);
    });
  }

  Future<void> addReport(ReportModel report) async {
    await _reports.add(report.toMap());
  }

  Future<void> updateStatus(String reportId, String status) async {
    await _reports.doc(reportId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
