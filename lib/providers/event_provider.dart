import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:samadhan_app/services/database_service.dart';

class Event {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String attendanceSummary;
  final List<String> photoPaths; // Storing paths for now

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.attendanceSummary = 'N/A',
    this.photoPaths = const [],
  });

  factory Event.fromMap(Map<String, dynamic> map, int id) {
    return Event(
      id: id,
      title: map['title'] as String,
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      time: TimeOfDay(
        hour: int.parse(map['time'].split(':')[0]),
        minute: int.parse(map['time'].split(':')[1]),
      ),
      attendanceSummary: map['attendanceSummary'] as String,
      photoPaths: List<String>.from(map['photoPaths'] as List),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'attendanceSummary': attendanceSummary,
      'photoPaths': photoPaths,
    };
  }

  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    String? attendanceSummary,
    List<String>? photoPaths,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      attendanceSummary: attendanceSummary ?? this.attendanceSummary,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }
}

class EventProvider with ChangeNotifier {
  final _eventStore = intMapStoreFactory.store('events');
  final DatabaseService _dbService = DatabaseService();

  List<Event> _events = [];
  List<Event> get events => _events;

  Future<void> loadEvents() async {
    final db = await _dbService.database;
    final snapshots = await _eventStore.find(db, finder: Finder(sortOrders: [SortOrder('date', false)])); // Sort by date descending
    _events = snapshots.map((snapshot) {
      return Event.fromMap(snapshot.value, snapshot.key);
    }).toList();
    notifyListeners();
  }

  Future<void> addEvent({
    required String title,
    required String description,
    required DateTime date,
    required TimeOfDay time,
    String attendanceSummary = 'N/A',
    List<String> photoPaths = const [],
  }) async {
    final db = await _dbService.database;
    final newEvent = Event(
      id: 0, // Sembast generates ID
      title: title,
      description: description,
      date: date,
      time: time,
      attendanceSummary: attendanceSummary,
      photoPaths: photoPaths,
    );
    await _eventStore.add(db, newEvent.toMap());
    await loadEvents();
  }

  Future<void> updateEvent(Event event) async {
    final db = await _dbService.database;
    await _eventStore.update(db, event.toMap(), finder: Finder(filter: Filter.byKey(event.id)));
    await loadEvents();
  }

  Future<void> deleteEvent(int id) async {
    final db = await _dbService.database;
    await _eventStore.delete(db, finder: Finder(filter: Filter.byKey(id)));
    await loadEvents();
  }
}
