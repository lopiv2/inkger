import 'package:flutter/material.dart';

class EditableTableCell extends StatelessWidget {
  final String value;
  final bool isEditing;
  final ValueChanged<String> onChanged;
  final VoidCallback onDoubleTap;
  final VoidCallback onEditingComplete;

  const EditableTableCell({
    Key? key,
    required this.value,
    required this.isEditing,
    required this.onChanged,
    required this.onDoubleTap,
    required this.onEditingComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return FocusScope(
        child: TextField(
          autofocus: true,
          controller: TextEditingController(text: value)
            ..selection = TextSelection.fromPosition(TextPosition(offset: value.length)),
          onChanged: onChanged,
          onSubmitted: (_) => onEditingComplete(),
          onEditingComplete: onEditingComplete,
        ),
      );
    } else {
      return InkWell(
        onDoubleTap: onDoubleTap,
        child: value.isNotEmpty
            ? Text(value)
            : Text(
                'Doble click para editar',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
      );
    }
  }
}
