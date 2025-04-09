import 'package:flutter/material.dart';

class NameGenerator {
  final String title;
  final IconData mainIcon;
  final List<GeneratorSection> sections;

  NameGenerator({
    required this.title,
    required this.mainIcon,
    required this.sections,
  });
}

class GeneratorSection {
  final String title;
  final IconData icon;
  final List<String>? subitems; // Opcional: items anidados

  GeneratorSection({
    required this.title,
    required this.icon,
    this.subitems,
  });
}
