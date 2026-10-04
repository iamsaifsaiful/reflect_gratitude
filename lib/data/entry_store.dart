import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/entry.dart';

/// Where entries and the user's name are kept.
///
/// The app talks only to this interface. Today it is backed by on-device
/// storage ([PrefsEntryStore]). To add accounts and sync later, write a
/// Supabase or Firebase implementation of this class and pass it to AppState
/// in main.dart; no screen needs to change.
abstract class EntryStore {
  Future<Map<String, Entry>> loadEntries();
  Future<void> saveEntry(Entry entry);
  Future<void> deleteEntry(String key);
  Future<String?> loadName();
  Future<void> saveName(String name);
}

/// Stores everything on the device with shared_preferences.
/// Entries are kept as one JSON object keyed by date ("2026-09-09").
class PrefsEntryStore implements EntryStore {
  static const _entriesKey = 'entries_v1';
  static const _nameKey = 'display_name';

  SharedPreferences? _prefs;
  Map<String, Entry> _cache = {};

  Future<SharedPreferences> get _instance async => _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<Map<String, Entry>> loadEntries() async {
    final prefs = await _instance;
    final raw = prefs.getString(_entriesKey);
    if (raw == null || raw.isEmpty) {
      _cache = {};
      return {};
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _cache = {
        for (final item in decoded.entries)
          item.key: Entry.fromJson(Map<String, dynamic>.from(item.value as Map)),
      };
    } catch (_) {
      // Corrupt data should never lock someone out of the app.
      _cache = {};
    }
    return Map.of(_cache);
  }

  @override
  Future<void> saveEntry(Entry entry) async {
    _cache[entry.key] = entry;
    await _write();
  }

  @override
  Future<void> deleteEntry(String key) async {
    _cache.remove(key);
    await _write();
  }

  Future<void> _write() async {
    final prefs = await _instance;
    final encoded = jsonEncode({for (final e in _cache.entries) e.key: e.value.toJson()});
    await prefs.setString(_entriesKey, encoded);
  }

  @override
  Future<String?> loadName() async => (await _instance).getString(_nameKey);

  @override
  Future<void> saveName(String name) async {
    await (await _instance).setString(_nameKey, name);
  }
}

/// In-memory store for tests and previews.
class MemoryEntryStore implements EntryStore {
  MemoryEntryStore({Map<String, Entry>? entries, this.name}) : _entries = {...?entries};

  final Map<String, Entry> _entries;
  String? name;

  @override
  Future<Map<String, Entry>> loadEntries() async => Map.of(_entries);

  @override
  Future<void> saveEntry(Entry entry) async {
    _entries[entry.key] = entry;
  }

  @override
  Future<void> deleteEntry(String key) async {
    _entries.remove(key);
  }

  @override
  Future<String?> loadName() async => name;

  @override
  Future<void> saveName(String value) async {
    name = value;
  }
}
