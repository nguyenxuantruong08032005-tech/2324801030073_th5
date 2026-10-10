
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

class NoteStorageService {
  static const String _storageKey = 'personal_notes_v1';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  // Đọc danh sách ghi chú
  Future<List<Note>> getNotes() async {
    final String? data = await _prefs.getString(_storageKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(data) as List<dynamic>;

    final List<Note> notes = decoded.map((item) {
      return Note.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();

    // Ghi chú mới nhất hiển thị trước
    notes.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return notes;
  }

  // Lưu toàn bộ danh sách
  Future<void> _saveAll(List<Note> notes) async {
    final String data = jsonEncode(
      notes.map((note) => note.toJson()).toList(),
    );

    await _prefs.setString(_storageKey, data);
  }

  // Thêm hoặc cập nhật ghi chú
  Future<void> saveNote(Note note) async {
    final notes = await getNotes();

    final index = notes.indexWhere(
      (item) => item.id == note.id,
    );

    if (index == -1) {
      notes.add(note);
    } else {
      notes[index] = note;
    }

    await _saveAll(notes);
  }

  // Xóa ghi chú theo ID
  Future<void> deleteNote(String id) async {
    final notes = await getNotes();

    notes.removeWhere((note) => note.id == id);

    await _saveAll(notes);
  }
}
