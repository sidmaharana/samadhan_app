import 'package:flutter/material.dart';
import 'package:samadhan_app/services/database_service.dart';
import 'package:sembast/sembast.dart';

class VolunteerReport {
  final int id;
  final String volunteerName;
  final List<String> selectedStudents;
  final String classBatch;
  final String inTime;
  final String outTime;
  final String activityTaught;
  final bool testConducted;
  final String? testTopic;
  final String? marksGrade;

  VolunteerReport({
    required this.id,
    required this.volunteerName,
    required this.selectedStudents,
    required this.classBatch,
    required this.inTime,
    required this.outTime,
    required this.activityTaught,
    required this.testConducted,
    this.testTopic,
    this.marksGrade,
  });

  factory VolunteerReport.fromMap(Map<String, dynamic> map, int id) {
    return VolunteerReport(
      id: id,
      volunteerName: map['volunteerName'],
      selectedStudents: List<String>.from(map['selectedStudents']),
      classBatch: map['classBatch'],
      inTime: map['inTime'],
      outTime: map['outTime'],
      activityTaught: map['activityTaught'],
      testConducted: map['testConducted'],
      testTopic: map['testTopic'],
      marksGrade: map['marksGrade'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'volunteerName': volunteerName,
      'selectedStudents': selectedStudents,
      'classBatch': classBatch,
      'inTime': inTime,
      'outTime': outTime,
      'activityTaught': activityTaught,
      'testConducted': testConducted,
      'testTopic': testTopic,
      'marksGrade': marksGrade,
    };
  }
}

class VolunteerProvider with ChangeNotifier {
  final _reportStore = intMapStoreFactory.store('volunteer_reports');
  final DatabaseService _dbService = DatabaseService();

  List<VolunteerReport> _reports = [];
  List<VolunteerReport> get reports => _reports;

  Future<void> addReport(VolunteerReport report) async {
    final db = await _dbService.database;
    await _reportStore.add(db, report.toMap());
    await fetchReports(); // refetch to update the list
  }
  
  Future<void> updateReport(VolunteerReport report) async {
    final db = await _dbService.database;
    await _reportStore.update(db, report.toMap(), finder: Finder(filter: Filter.byKey(report.id)));
    await fetchReports();
  }
  
  Future<void> deleteMultipleReports(List<int> ids) async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      await _reportStore.delete(txn, finder: Finder(filter: Filter.byKey(ids)));
    });
    await fetchReports();
  }

  Future<void> fetchReports() async {
    final db = await _dbService.database;
    final snapshots = await _reportStore.find(db);
    _reports = snapshots.map((snapshot) {
      return VolunteerReport.fromMap(snapshot.value, snapshot.key);
    }).toList();
    notifyListeners();
  }
}
