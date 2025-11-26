import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:samadhan_app/providers/student_provider.dart';
import 'package:samadhan_app/services/face_recognition_service.dart';
import 'package:samadhan_app/providers/notification_provider.dart';
import 'package:samadhan_app/providers/offline_sync_provider.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollNoController = TextEditingController();
  String? _selectedClassBatch;
  final List<String> _classBatches = ['Class 1', 'Class 2', 'Class 3', 'Batch A', 'Batch B'];

  final List<File?> _photoFiles = List.filled(5, null);
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      setState(() {
        _photoFiles[index] = File(image.path);
      });
    }
  }

  Future<void> _addStudentAndTrain({bool isOnline = false}) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      final offlineSyncProvider = Provider.of<OfflineSyncProvider>(context, listen: false);

      setState(() {
        _isLoading = true;
      });

      try {
        final newStudent = await studentProvider.addStudent(
          name: _nameController.text,
          rollNo: _rollNoController.text,
          classBatch: _selectedClassBatch!,
        );

        offlineSyncProvider.addPendingChange();

        final trainingPhotos = _photoFiles.where((f) => f != null).cast<File>().toList();

        if (isOnline && trainingPhotos.isNotEmpty) {
          final faceService = FaceRecognitionService();
          final trainResponse = await faceService.trainFace(newStudent.id, newStudent.name, trainingPhotos);

          if (trainResponse.containsKey('error')) {
            notificationProvider.addNotification(
              title: 'Student Added (Training Failed)',
              message: 'Student ${newStudent.name} added, but face training failed: ${trainResponse['error']}',
              type: 'alert',
            );
          } else {
            notificationProvider.addNotification(
              title: 'Student Added & Trained',
              message: 'Student ${newStudent.name} added and face training started successfully!',
              type: 'success',
            );
          }
        } else {
          notificationProvider.addNotification(
            title: 'Student Added (Offline)',
            message: 'Student ${newStudent.name} added. Face training will sync when online.',
            type: 'warning',
          );
        }
        
        if (mounted) {
          Navigator.pop(context);
        }

      } catch (e) {
        notificationProvider.addNotification(
          title: 'Failed to Add Student',
          message: 'An error occurred while adding student: $e',
          type: 'alert',
        );
      } finally {
        if(mounted){
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Student'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter student name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rollNoController,
                decoration: const InputDecoration(
                  labelText: 'Roll Number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter roll number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Class/Batch',
                ),
                value: _selectedClassBatch,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedClassBatch = newValue;
                  });
                },
                items: _classBatches.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a class/batch';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('Upload Photos for Training (5 slots)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _pickImage(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _photoFiles[index] == null
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_photoFiles[index]!, fit: BoxFit.cover),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Consumer<OfflineSyncProvider>(
                  builder: (context, syncProvider, child) {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => _addStudentAndTrain(isOnline: syncProvider.isOnline),
                          child: Text(syncProvider.isOnline ? 'ADD STUDENT & TRAIN' : 'Add Student (Offline)', style: const TextStyle(fontSize: 18)),
                        ),
                        if (!syncProvider.isOnline)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Face training requires an internet connection and will be synced later.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
