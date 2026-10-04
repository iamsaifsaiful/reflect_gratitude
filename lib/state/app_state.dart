import 'package:flutter/widgets.dart';

import '../data/content.dart';
import '../data/entry_store.dart';
import '../logic/dates.dart';
import '../logic/streaks.dart';
import '../models/entry.dart';

/// Holds the user's entries and name, and exposes everything the screens need.
class AppState extends ChangeNotifier {
  AppState({
    required this.store,
    required this.content,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final EntryStore store;
  final ContentRepository content;
  final DateTime Function() _clock;

  Map<String, Entry> _entries = {};
  String? _name;
  ProgressStats? _stats;
  String? _statsDay;

  DateTime get now => _clock();
  DateTime get today => dayOnly(_clock());

  String get name => (_name ?? '').trim();
  bool get needsWelcome => name.isEmpty;

  Future<void> load() async {
    _entries = await store.loadEntries();
    _name = await store.loadName();
    _invalidate();
    notifyListeners();
  }

  Future<void> setName(String value) async {
    _name = value.trim();
    notifyListeners();
    await store.saveName(_name!);
  }

  Entry entryFor(DateTime day) => _entries[dateKey(day)] ?? Entry(date: day);

  /// Entries with content between [start] and [end] (inclusive), newest first.
  List<Entry> entriesBetween(DateTime start, DateTime end) {
    final from = dayOnly(start);
    final to = dayOnly(end);
    final list = _entries.values
        .where((e) => e.hasContent && daysBetween(from, e.date) >= 0 && daysBetween(e.date, to) >= 0)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  bool isWritten(DateTime day) => _entries[dateKey(day)]?.hasContent ?? false;

  int answeredOn(DateTime day) => _entries[dateKey(day)]?.answeredCount ?? 0;

  Set<String> get writtenDays =>
      _entries.values.where((e) => e.hasContent).map((e) => e.key).toSet();

  ProgressStats get stats {
    final key = dateKey(today);
    if (_stats == null || _statsDay != key) {
      _stats = computeStats(writtenDays, today);
      _statsDay = key;
    }
    return _stats!;
  }

  /// Saves an entry, or removes it when every section is empty.
  Future<void> saveEntry(Entry entry) async {
    final existing = _entries[entry.key];
    if (!entry.hasContent) {
      if (existing == null) return;
      _entries.remove(entry.key);
      _invalidate();
      notifyListeners();
      await store.deleteEntry(entry.key);
      return;
    }
    if (existing != null && _sameText(existing, entry)) return;
    _entries[entry.key] = entry;
    _invalidate();
    notifyListeners();
    await store.saveEntry(entry);
  }

  bool _sameText(Entry a, Entry b) =>
      a.reflection == b.reflection &&
      a.gratitude == b.gratitude &&
      a.successes == b.successes &&
      a.finalThoughts == b.finalThoughts;

  void _invalidate() {
    _stats = null;
    _statsDay = null;
  }
}

/// Makes [AppState] available to every screen below it.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  /// Use in build methods: rebuilds the widget when the state changes.
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Use in callbacks and initState: no rebuild dependency.
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
