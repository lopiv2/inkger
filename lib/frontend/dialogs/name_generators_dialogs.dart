import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/name_generator.dart';

class NameGeneratorsDialog extends StatefulWidget {
  final NameGenerator generator;
  final List<String> sections;

  const NameGeneratorsDialog({
    super.key,
    required this.generator,
    required this.sections,
  });

  @override
  State<NameGeneratorsDialog> createState() => _NameGeneratorsDialogState();
}

class _NameGeneratorsDialogState extends State<NameGeneratorsDialog> {
  late String selectedSection;

  @override
  void initState() {
    super.initState();
    selectedSection = widget.sections.first;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 600,
        height: 400,
        child: Row(
          children: [
            // Columna izquierda
            Container(
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
              child: ListView(
                children: widget.sections.map((section) {
                  final isSelected = section == selectedSection;
                  return ListTile(
                    title: Text(
                      section,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedSection = section;
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            // Columna derecha
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildSectionContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent() {
    // Puedes usar un switch o un map personalizado por sección si lo necesitas
    switch (selectedSection) {
      case 'Basic':
        return _basicOptions();
      case 'Advanced':
        return _advancedOptions();
      case 'Themes':
        return _themeOptions();
      case 'Options':
        return _miscOptions();
      default:
        return Center(
          child: Text(
            'Contenido para "${selectedSection}"',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
    }
  }

  Widget _basicOptions() => _sectionTemplate('Basic Settings');
  Widget _advancedOptions() => _sectionTemplate('Advanced Settings');
  Widget _themeOptions() => _sectionTemplate('Theme Options');
  Widget _miscOptions() => _sectionTemplate('Misc Options');

  Widget _sectionTemplate(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 8),
        const Text(
          'Aquí puedes personalizar las opciones relacionadas.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
