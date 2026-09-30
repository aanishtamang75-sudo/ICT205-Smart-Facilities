import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String title;
  final String description;
  final String assetType;
  final String area;
  final String priority;
  final String status;
  final String imageUrl;
  final String location;
  final String createdBy;
  final String createdByEmail;
  final Timestamp? createdAt;

  ReportModel({
    this.id = '',
    required this.title,
    required this.description,
    required this.assetType,
    this.area = '',
    this.priority = 'Medium',
    this.status = 'Open',
    this.imageUrl = '',
    this.location = '',
    this.createdBy = '',
    this.createdByEmail = '',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'assetType': assetType,
      'area': area,
      'priority': priority,
      'status': status,
      'imageUrl': imageUrl,
      'location': location,
      'createdBy': createdBy,
      'createdByEmail': createdByEmail,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory ReportModel.fromMap(String id, Map<String, dynamic> map) {
    return ReportModel(
      id: id,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      assetType: map['assetType']?.toString() ?? 'Other',
      area: map['area']?.toString() ?? '',
      priority: map['priority']?.toString() ?? 'Medium',
      status: map['status']?.toString() ?? 'Open',
      imageUrl: map['imageUrl']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      createdBy: map['createdBy']?.toString() ?? '',
      createdByEmail: map['createdByEmail']?.toString() ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt'] as Timestamp
          : null,
    );
  }

  int get workflowRank {
    switch (status) {
      case 'Open':
        return 0;
      case 'In progress':
        return 1;
      default:
        return 2;
    }
  }

  int get priorityRank {
    switch (priority) {
      case 'High':
        return 0;
      case 'Medium':
        return 1;
      default:
        return 2;
    }
  }

  String get nextStatus {
    switch (status) {
      case 'Open':
        return 'In progress';
      case 'In progress':
        return 'Resolved';
      default:
        return 'Open';
    }
  }

  String get nextActionLabel {
    switch (status) {
      case 'Open':
        return 'Start work';
      case 'In progress':
        return 'Mark as resolved';
      default:
        return 'Reopen report';
    }
  }
}
