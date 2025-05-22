import 'package:flutter/material.dart';

class VersionsScreen extends StatelessWidget {
  const VersionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String installedVersion = "1.0.0"; // Versión instalada (ejemplo)
    final bool hasNewVersion = true; // Indica si hay una nueva versión disponible
    final List<String> features = [
      "Feature 1: Descripción de la característica",
      "Feature 2: Descripción de la característica",
      "Feature 3: Descripción de la característica",
    ]; // Lista de características de la versión actual

    return Scaffold(
      appBar: AppBar(
        title: const Text("Versiones"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Versión instalada: $installedVersion",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              hasNewVersion
                  ? "¡Hay una nueva versión disponible!"
                  // ignore: dead_code
                  : "Estás utilizando la última versión.",
              style: TextStyle(
                fontSize: 16,
                // ignore: dead_code
                color: hasNewVersion ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Características de la versión actual:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.blue),
                    title: Text(features[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}