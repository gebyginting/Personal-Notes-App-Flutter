import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:personal_notes/models/note.dart';
import 'package:personal_notes/utils/colors.dart';
import 'package:personal_notes/ui/add_edit_note_page.dart';
import 'package:personal_notes/utils/search_bar.dart';
import 'package:personal_notes/videmodel/notes_view_model.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late Future<void> _notesFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Note> filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _notesFuture = _fetchNotesAndSetFiltered();
  }

  Future<void> _fetchNotesAndSetFiltered() async {
    final notesVM = Provider.of<NotesViewModel>(context, listen: false);
    await notesVM.fetchNotes();
    setState(() {
      filteredNotes = notesVM.notes;
    });
  }

  void onSearchTextChanged(String searchText) {
    final notesVM = Provider.of<NotesViewModel>(context, listen: false);
    setState(() {
      if (searchText.isEmpty) {
        filteredNotes = notesVM.notes;
      } else {
        filteredNotes = NoteSearchHelper.filterNotes(searchText, notesVM.notes);
      }
    });
  }

  Color getRandomColor() {
    final random = Random();
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    final notesVM = Provider.of<NotesViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: FutureBuilder(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (filteredNotes.isEmpty) {
            return const Center(child: Text('No notes found.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: onSearchTextChanged,
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddEditNotePage(note: note),
                            ),
                          );

                          if (result == true) {
                            _searchController.clear();
                            await _fetchNotesAndSetFiltered();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: getRandomColor(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                note.content,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 30,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddEditNotePage()));

          if (result == true) {
            _searchController.clear();
            await _fetchNotesAndSetFiltered();
          }
        },
      ),
    );
  }
}
