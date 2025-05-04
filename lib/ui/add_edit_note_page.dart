import 'package:flutter/material.dart';
import 'package:personal_notes/db/notes_database.dart';
import 'package:personal_notes/models/note.dart';
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
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'Add Note'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveNote)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter Title' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 6,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter Content' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
