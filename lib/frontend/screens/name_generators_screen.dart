import 'package:flutter/material.dart';
import 'package:inkger/frontend/dialogs/name_generators_dialogs.dart';
import 'package:inkger/frontend/models/name_generator.dart'; // Asegúrate de importar tu modelo

class NameGeneratorsScreen extends StatelessWidget {
  // Ejemplo de datos para los generadores
  final List<NameGenerator> generators = [
    NameGenerator(
      title: 'Creatures',
      icon: Icons.catching_pokemon,
      sections: ['Basic', 'Mythical', 'Hybrids'],
    ),
    NameGenerator(
      title: 'Names',
      icon: Icons.text_fields,
      sections: ['First Names', 'Last Names', 'Nicknames'],
    ),
    NameGenerator(
      title: 'More',
      icon: Icons.more_horiz,
      sections: ['Rare', 'Obscure'],
    ),
    NameGenerator(
      title: 'Oceans',
      icon: Icons.water,
      sections: ['Shallow', 'Deep', 'Abyssal'],
    ),
    NameGenerator(
      title: 'Places',
      icon: Icons.location_on,
      sections: ['Cities', 'Villages', 'Ruins'],
    ),
    NameGenerator(
      title: 'Planets',
      icon: Icons.public,
      sections: ['Terrestrial', 'Gas Giants', 'Dwarf Planets'],
    ),
    NameGenerator(
      title: 'Races',
      icon: Icons.people,
      sections: ['Humanoid', 'Beast', 'Spirit', 'Elves', 'Dwarven'],
    ),
    NameGenerator(
      title: 'Spells',
      icon: Icons.people,
      sections: ['Fire', 'Water', 'Dark'],
    ),
    NameGenerator(
      title: 'Tech',
      icon: Icons.memory,
      sections: ['AI', 'Robotics', 'Nanotech'],
    ),
    NameGenerator(
      title: 'Vehicles',
      icon: Icons.directions_car,
      sections: ['Land', 'Air', 'Space'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: const Text(
          "Name Generators",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: generators.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // Ajusta según tus necesidades
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3, // Tarjeta más horizontal
          ),
          itemBuilder: (context, index) {
            return _buildGeneratorCard(
              context,
              generators[index],
              generators[index].sections,
            );
          },
        ),
      ),
    );
  }

  Widget _buildGeneratorCard(
    BuildContext context,
    NameGenerator generator,
    List<String> sections,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bordes redondeados
      ),
      child: InkWell(
        onTap: () {
          showGeneratorDialog(
            context,
            generator,
            sections,
          ); // Puedes personalizar por generador si quieres); // ← Llama al diálogo aquí
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(
                generator.icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  generator.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showGeneratorDialog(
    BuildContext context,
    NameGenerator generator,
    List<String> sections,
  ) {
    showDialog(
      context: context,
      builder:
          (context) =>
              NameGeneratorsDialog(generator: generator, sections: sections),
    );
  }
}
