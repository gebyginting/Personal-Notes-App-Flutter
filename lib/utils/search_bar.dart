import 'package:personal_notes/models/note.dart';

class NoteSearchHelper {
  static List<Note> filterNotes(String query, List<Note> notes) {
    return notes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(query.toLowerCase());
      return titleMatch;
    }).toList();
  }
}
