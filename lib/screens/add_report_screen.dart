import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/report_model.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/report_service.dart';
import '../services/storage_service.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final titleController = TextEditingController();
  final areaController = TextEditingController();
  final descriptionController = TextEditingController();
  final picker = ImagePicker();
  final locationService = LocationService();
  final storage = StorageService();
  final reports = ReportService();
  final auth = AuthService();

  final assetTypes = const [
    'Lighting',
    'Plumbing',
    'Furniture',
    'HVAC',
    'Other',
  ];
  final priorities = const ['High', 'Medium', 'Low'];

  String assetType = 'Lighting';
  String priority = 'Medium';
  String currentLocation = '';
  File? selectedImage;
  bool _isSaving = false;

  @override
  void dispose() {
    titleController.dispose();
    areaController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> captureImage() async {
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      if (cameraStatus.isPermanentlyDenied) {
        await openAppSettings();
      }
      if (!mounted) return;
      _showMessage('Camera permission is required to photograph the issue');
      return;
    }

    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (picked == null) return;
    setState(() => selectedImage = File(picked.path));
  }

  Future<void> loadLocation() async {
    final position = await locationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        currentLocation = '${position.latitude}, ${position.longitude}';
      });
      return;
    }
    if (!mounted) return;
    _showMessage('Turn on GPS and allow location so staff can find the asset.');
  }

  Future<void> _save() async {
    if (titleController.text.trim().isEmpty) {
      _showMessage('Please enter a short title');
      return;
    }
    if (areaController.text.trim().isEmpty) {
      _showMessage('Enter the building or room so staff know where to go');
      return;
    }
    if (descriptionController.text.trim().length < 8) {
      _showMessage('Add a short description of what is wrong');
      return;
    }
    if (selectedImage == null) {
      _showMessage('Take a photo of the issue so staff can see the problem');
      return;
    }
    if (currentLocation.isEmpty) {
      _showMessage('Get location first so the report includes GPS');
      return;
    }

    final user = auth.getCurrentUser();
    if (user == null) {
      _showMessage('Please log in again');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final imageUrl = await storage.uploadFacilityImage(selectedImage!, user.uid);
      await reports.addReport(
        ReportModel(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          assetType: assetType,
          area: areaController.text.trim(),
          priority: priority,
          status: 'Open',
          imageUrl: imageUrl,
          location: currentLocation,
          createdBy: user.uid,
          createdByEmail: user.email ?? '',
        ),
      );
      if (!mounted) return;
      _showMessage('Report submitted');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not save report. Check Storage and Firestore rules.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New facility report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isSaving) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Broken light in Room 204',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: areaController,
            decoration: const InputDecoration(
              labelText: 'Building / room',
              hintText: 'e.g. Building A, Room 204',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _SimpleDropdown(
            label: 'Asset type',
            value: assetType,
            items: assetTypes,
            onChanged: (value) => setState(() => assetType = value),
          ),
          const SizedBox(height: 12),
          _SimpleDropdown(
            label: 'Priority',
            value: priority,
            items: priorities,
            onChanged: (value) => setState(() => priority = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(selectedImage!, height: 180, fit: BoxFit.cover),
            )
          else
            const Text('No photo yet. Open Camera to capture the issue.'),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : captureImage,
            icon: const Icon(Icons.photo_camera),
            label: const Text('Open Camera'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : loadLocation,
            icon: const Icon(Icons.my_location),
            label: const Text('Get Location'),
          ),
          const SizedBox(height: 8),
          Text(
            [
              selectedImage == null ? 'Photo: missing' : 'Photo: captured',
              currentLocation.isEmpty
                  ? 'GPS: missing'
                  : 'GPS: $currentLocation',
            ].join('\n'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: const Text('Submit report'),
          ),
        ],
      ),
    );
  }
}

class _SimpleDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _SimpleDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ),
    );
  }
}
