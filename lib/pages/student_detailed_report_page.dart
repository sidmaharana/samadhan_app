import 'package:flutter/material.dart';
import 'package:samadhan_app/providers/student_provider.dart';

class StudentDetailedReportPage extends StatelessWidget {
  final Student student;

  const StudentDetailedReportPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${student.name}\'s Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to Student Report Page
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Section
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, size: 60, color: Colors.white), // Large photo placeholder
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Name: ${student.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Roll No: ${student.rollNo}', style: const TextStyle(fontSize: 16)),
                    Text('Class: ${student.classBatch}', style: const TextStyle(fontSize: 16)),
                    const Text('Center: Center A - Mumbai', style: TextStyle(fontSize: 16)), // Placeholder
                  ],
                ),
              ),
            ),

            // 2. Attendance Summary
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Attendance Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    // Placeholder for Monthly attendance graph
                    Container(
                      height: 100,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Text('Monthly Attendance Graph (Placeholder)'),
                    ),
                    const SizedBox(height: 10),
                    const Text('Percentage: 85%', style: TextStyle(fontSize: 16)), // Placeholder
                    const Text('Total classes present: 120/140', style: TextStyle(fontSize: 16)), // Placeholder
                  ],
                ),
              ),
            ),

            // 3. Learning Progress
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Learning Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text('Progress Bar (Placeholder):', style: TextStyle(fontSize: 16)),
                    LinearProgressIndicator(value: 0.75, minHeight: 10, borderRadius: BorderRadius.circular(5)), // Placeholder
                    const SizedBox(height: 10),
                    const Text('Chapters completed: 10/12', style: TextStyle(fontSize: 16)), // Placeholder
                    const Text('Skills mastered: Reading, Writing, Basic Math', style: TextStyle(fontSize: 16)), // Placeholder
                    const Text('Remarks: Consistent effort, good participation.', style: TextStyle(fontSize: 16)), // Placeholder
                  ],
                ),
              ),
            ),

            // 4. Test Results
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Test Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    // Placeholder for Table of tests
                    Container(
                      height: 100,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Text('Table of Tests (Placeholder)'),
                    ),
                    const SizedBox(height: 10),
                    // Placeholder for Score trends graph
                    Container(
                      height: 100,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Text('Score Trends Graph (Placeholder)'),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Additional Metrics
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Additional Metrics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text('Volunteer effectiveness score: 4.5/5', style: TextStyle(fontSize: 16)), // Placeholder
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
