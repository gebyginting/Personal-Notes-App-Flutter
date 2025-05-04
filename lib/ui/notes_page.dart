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
    _notesFuture = Provider.of<NotesViewModel>(
      context,
      listen: false,
    ).fetchNotes().then((_) {
      final notes = Provider.of<NotesViewModel>(context, listen: false).notes;
      setState(() {
        filteredNotes = notes;
      });
    });
  }

  void onSearchTextChanged(String searchText) {
    final notesVM = Provider.of<NotesViewModel>(context, listen: false);
    setState(() {
      filteredNotes = NoteSearchHelper.filterNotes(searchText, notesVM.notes);
    });
  }

  getRandomColor() {
    Random random = Random();
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
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(child: CircularProgressIndicator());
          // }

          final notes = notesVM.notes;

          if (notes.isEmpty) {
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
                    prefixIcon: Icon(Icons.search),
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
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddEditNotePage(note: note),
                            ),
                          );
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
            setState(() {
              _searchController.clear();
              _notesFuture = notesVM.fetchNotes();
            });
          }
        },
      ),
    );
  }
}

          //   return ListView.builder(
          //     itemCount: notesVM.notes.length,
          //     itemBuilder: (context, index) {
          //       final note = notesVM.notes[index];
          //       return ListTile(
          //         title: Text(note.title),
          //         subtitle: Text(note.content),
          //         trailing: IconButton(
          //           onPressed: () => notesVM.deleteNote(note.id!),
          //           icon: Icon(Icons.delete),
          //         ),
          //       );
          //     },
          //   );
          // },
