import 'package:flutter_test/flutter_test.dart';
import 'package:personal_bio_app/models/report_model.dart';

void main() {
  test('ReportModel maps fields and next status', () {
    final report = ReportModel(
      title: 'Broken light',
      description: 'Flickering in room 204',
      assetType: 'Lighting',
      area: 'Building A, Room 204',
      priority: 'High',
      status: 'Open',
      location: '37.42, -122.08',
      createdBy: 'uid123',
      createdByEmail: 'anish@gg.com',
    );
    final map = report.toMap();
    expect(map['title'], 'Broken light');
    expect(map['area'], 'Building A, Room 204');
    expect(map['priority'], 'High');
    expect(report.nextStatus, 'In progress');
    expect(report.nextActionLabel, 'Start work');

    final restored = ReportModel.fromMap('abc', map);
    expect(restored.id, 'abc');
    expect(restored.priority, 'High');
    expect(restored.workflowRank, 0);
  });
}
