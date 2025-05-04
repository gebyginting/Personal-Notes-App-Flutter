import 'package:flutter/material.dart';
import 'package:personal_notes/db/notes_database.dart';
import 'package:personal_notes/models/note.dart';

class NotesViewModel extends ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  Future<void> fetchNotes() async {
    _notes = await NotesDatabase.instance.readAllNotes();
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await NotesDatabase.instance.create(note);
    await fetchNotes();
  }

  Future<void> updateNote(Note note) async {
    await NotesDatabase.instance.update(note);
    await fetchNotes();
  }

  Future<void> deleteNote(int id) async {
    await NotesDatabase.instance.delete(id);
    await fetchNotes();
  }
}
