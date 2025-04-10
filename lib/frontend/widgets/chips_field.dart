import 'package:flutter/material.dart';

class ChipsField extends StatefulWidget {
  final String label;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  const ChipsField({
    Key? key,
    required this.label,
    required this.values,
    required this.onChanged,
  }) : super(key: key);

  @override
  _ChipsFieldState createState() => _ChipsFieldState();
}

class _ChipsFieldState extends State<ChipsField> {
  late List<String> _currentValues;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentValues = List.from(widget.values);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Container(
                width: 100,
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // Chips
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _currentValues.map((value) {
                    return Chip(
                      label: Text(value),
                      onDeleted: () {
                        setState(() {
                          _currentValues.remove(value);
                          widget.onChanged(_currentValues);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Añadir nuevo',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (text) {
              final newTags = text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty && !_currentValues.contains(e))
                  .toList();

              if (newTags.isNotEmpty) {
                setState(() {
                  _currentValues.addAll(newTags);
                  _textController.clear();
                  widget.onChanged(_currentValues);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}