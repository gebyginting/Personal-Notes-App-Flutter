import 'package:flutter/material.dart';
import 'package:personal_notes/utils/colors.dart';

class NoteForm extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;

  const NoteForm({
    super.key,
    required this.titleController,
    required this.contentController,
  });

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  static const int _maxContentLength = 200;
  int _remainingCharacters = _maxContentLength;

  @override
  void initState() {
    super.initState();
    widget.contentController.addListener(_updateRemainingCharacters);
    _updateRemainingCharacters(); // Initial update
  }

  void _updateRemainingCharacters() {
    setState(() {
      _remainingCharacters =
          _maxContentLength - widget.contentController.text.length;
    });
  }

  @override
  void dispose() {
    widget.contentController.removeListener(_updateRemainingCharacters);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Title",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.titleController,
          decoration: InputDecoration(
            hintText: 'Enter title...',
            filled: true,
            fillColor: const Color.fromARGB(255, 236, 225, 255),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator:
              (value) =>
                  value == null || value.isEmpty ? 'Title is required' : null,
        ),
        const SizedBox(height: 24),
        const Text(
          "Content",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.contentController,
          maxLines: 8,
          maxLength: _maxContentLength,
          decoration: InputDecoration(
            hintText: 'Write your note here...',
            filled: true,
            fillColor: const Color.fromARGB(255, 236, 225, 255),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            counterText: '', // Hide default counter
          ),
          validator:
              (value) =>
                  value == null || value.isEmpty ? 'Content is required' : null,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "$_remainingCharacters characters remaining",
            style: TextStyle(
              color: _remainingCharacters < 0 ? Colors.red : Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
