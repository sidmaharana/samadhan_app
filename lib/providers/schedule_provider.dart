import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:samadhan_app/services/database_service.dart';

class ScheduleEntry {
  final int id;
  final String classBatch;
  final DateTime date;
  final TimeOfDay time;
  final String topic;

  ScheduleEntry({
    required this.id,
    required this.classBatch,
    required this.date,
    required this.time,
    required this.topic,
  });

  factory ScheduleEntry.fromMap(Map<String, dynamic> map, int id) {
    return ScheduleEntry(
      id: id,
      classBatch: map['classBatch'] as String,
      date: DateTime.parse(map['date'] as String),
      time: TimeOfDay(
        hour: int.parse(map['time'].split(':')[0]),
        minute: int.parse(map['time'].split(':')[1]),
      ),
      topic: map['topic'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classBatch': classBatch,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'topic': topic,
    };
  }

  ScheduleEntry copyWith({
    int? id,
    String? classBatch,
    DateTime? date,
    TimeOfDay? time,
    String? topic,
  }) {
    return ScheduleEntry(
      id: id ?? this.id,
      classBatch: classBatch ?? this.classBatch,
      date: date ?? this.date,
      time: time ?? this.time,
      topic: topic ?? this.topic,
    );
  }
}

class ScheduleProvider with ChangeNotifier {
  final _scheduleStore = intMapStoreFactory.store('schedules');
  final DatabaseService _dbService = DatabaseService();

  List<ScheduleEntry> _schedules = [];
  List<ScheduleEntry> get schedules => _schedules;

  Future<void> loadSchedules() async {
    final db = await _dbService.database;
    final snapshots = await _scheduleStore.find(db, finder: Finder(sortOrders: [SortOrder('date', false)])); // Sort by date descending
    _schedules = snapshots.map((snapshot) {
      return ScheduleEntry.fromMap(snapshot.value, snapshot.key);
    }).toList();
    notifyListeners();
  }

  Future<void> addSchedule({
    required String classBatch,
    required DateTime date,
    required TimeOfDay time,
    required String topic,
  }) async {
    final db = await _dbService.database;
    final newEntry = ScheduleEntry(
      id: 0, // Sembast generates ID
      classBatch: classBatch,
      date: date,
      time: time,
      topic: topic,
    );
    await _scheduleStore.add(db, newEntry.toMap());
    await loadSchedules();
  }

  Future<void> updateSchedule(ScheduleEntry entry) async {
    final db = await _dbService.database;
    await _scheduleStore.update(db, entry.toMap(), finder: Finder(filter: Filter.byKey(entry.id)));
    await loadSchedules();
  }

  Future<void> deleteSchedule(int id) async {
    final db = await _dbService.database;
    await _scheduleStore.delete(db, finder: Finder(filter: Filter.byKey(id)));
    await loadSchedules();
  }
}
