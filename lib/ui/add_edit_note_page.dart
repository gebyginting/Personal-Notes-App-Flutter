import 'package:flutter/material.dart';
import 'package:personal_notes/models/note.dart';
import 'package:personal_notes/ui/add_edit/note_form.dart';
import 'package:personal_notes/videmodel/notes_view_model.dart';
import 'package:provider/provider.dart';

class AddEditNotePage extends StatefulWidget {
  final Note? note;

  const AddEditNotePage({Key? key, this.note}) : super(key: key);

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _deleteNote() async {
    final notesVM = Provider.of<NotesViewModel>(context, listen: false);
    if (widget.note != null && widget.note!.id != null) {
      await notesVM.deleteNote(widget.note!.id!);
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<NotesViewModel>();
      final note = Note(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        createdTime: DateTime.now(),
      );

      if (widget.note == null) {
        await viewModel.addNote(note);
      } else {
        await viewModel.updateNote(note);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          isEditing ? 'Edit Note' : 'Add Note',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                          'Are you sure you want to delete this note?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                );

                if (confirmed == true) {
                  await _deleteNote();
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                child: NoteForm(
                  titleController: _titleController,
                  contentController: _contentController,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                label: Text(
                  isEditing ? 'Update Note' : 'Save Note',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 132, 104, 181),
                  minimumSize: const Size.fromHeight(50), // tombol lebar penuh
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
