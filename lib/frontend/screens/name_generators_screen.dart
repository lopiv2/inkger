import 'package:flutter/material.dart';
import 'package:inkger/frontend/dialogs/name_generators_dialogs.dart';
import 'package:inkger/frontend/models/fantasy_icons.dart';
import 'package:inkger/frontend/models/name_generator.dart'; // Asegúrate de importar tu modelo

class NameGeneratorsScreen extends StatelessWidget {
  // Ejemplo de datos para los generadores
  final List<NameGenerator> generators = [
    NameGenerator(
      title: 'Creatures',
      mainIcon: Icons.catching_pokemon,
      sections: [
        GeneratorSection(title: 'Basic', icon: Icons.face),
        GeneratorSection(title: 'Mythical', icon: Icons.face_3),
        GeneratorSection(title: 'Hybrid', icon: Icons.face_3),
      ],
    ),
    NameGenerator(
      title: 'Names',
      mainIcon: Icons.text_fields,
      sections: [
        GeneratorSection(title: 'First names', icon: Icons.face),
        GeneratorSection(title: 'Last Names', icon: Icons.face_3),
        GeneratorSection(title: 'Nicknames', icon: Icons.face_3),
      ],
    ),
    NameGenerator(
      title: 'More',
      mainIcon: Icons.more_horiz,
      sections: [
        GeneratorSection(title: 'Rare', icon: Icons.face),
        GeneratorSection(title: 'Obscure', icon: Icons.face_3),
      ],
    ),
    NameGenerator(
      title: 'Water bodies',
      mainIcon: Fantasy.ocean,
      sections: [
        GeneratorSection(title: 'Sea', icon: Icons.face),
        GeneratorSection(title: 'Deep', icon: Icons.face_3),
        GeneratorSection(title: 'Abisal', icon: Icons.face_3),
        GeneratorSection(title: 'Lake', icon: Icons.face_3),
        GeneratorSection(title: 'Ocean', icon: Fantasy.ocean),
      ],
    ),
    NameGenerator(
      title: 'Places',
      mainIcon: Icons.location_on,
      sections: [
        GeneratorSection(title: 'Cities', icon: Icons.face),
        GeneratorSection(title: 'Villages', icon: Fantasy.village),
        GeneratorSection(title: 'Ruins', icon: Icons.face_3),
        GeneratorSection(title: 'Caves', icon: Icons.face_3),
        GeneratorSection(title: 'Places of Interes', icon: Icons.face_3),
      ],
    ),
    NameGenerator(
      title: 'Celestial Bodies',
      mainIcon: Icons.public,
      sections: [
        GeneratorSection(title: 'Terrestrial', icon: Icons.face),
        GeneratorSection(title: 'Giants', icon: Icons.face_3),
        GeneratorSection(title: 'Dwarf', icon: Icons.face_3),
        GeneratorSection(title: 'Stars', icon: Icons.face_3),
        GeneratorSection(title: 'Satellites', icon: Icons.face_3),
      ],
    ),
    NameGenerator(
      title: 'Races',
      mainIcon: Icons.people,
      sections: [
        GeneratorSection(title: 'Humanoid', icon: Fantasy.human),
        GeneratorSection(title: 'Beast', icon: Fantasy.werewolf),
        GeneratorSection(title: 'Spirit', icon: Icons.face_3),
        GeneratorSection(title: 'Elves', icon: Fantasy.elf),
        GeneratorSection(title: 'Dwarven', icon: Fantasy.dwarf),
      ],
    ),
    NameGenerator(
      title: 'Spells',
      mainIcon: Fantasy.magicWand,
      sections: [
        GeneratorSection(title: 'Fire', icon: Icons.face),
        GeneratorSection(title: 'Water', icon: Icons.face_3),
        GeneratorSection(title: 'Life', icon: Icons.face_3),
        GeneratorSection(title: 'Dark', icon: Icons.face_3),
        GeneratorSection(title: 'Wind', icon: Icons.face_3),
        GeneratorSection(title: 'Earth', icon: Icons.face_3),
        GeneratorSection(title: 'Lightning', icon: Icons.face_3),
      ],
    ),
    NameGenerator(
      title: 'Tech',
      mainIcon: Icons.memory,
      sections: [
        GeneratorSection(title: 'AI', icon: Icons.face),
        GeneratorSection(title: 'Robotics', icon: Icons.face_3),
        GeneratorSection(title: 'Nanotech', icon: Icons.face_3),
      ],
    ),
    NameGenerator(
      title: 'Vehicles',
      mainIcon: Icons.directions_car,
      sections: [
        GeneratorSection(title: 'Land', icon: Icons.face),
        GeneratorSection(title: 'Air', icon: Icons.face_3),
        GeneratorSection(title: 'Space', icon: Icons.face_3),
        GeneratorSection(title: 'Water', icon: Icons.face_3),
      ],
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
    List<GeneratorSection> sections,
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
                generator.mainIcon,
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
    List<GeneratorSection> sections,
  ) {
    showDialog(
      context: context,
      builder:
          (context) =>
              NameGeneratorsDialog(generator: generator, sections: sections),
    );
  }
}
