import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/comic_services.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VolumeIssuesDialog extends StatefulWidget {
  final List<Map<String, dynamic>> issues;
  final String volumeTitle;

  const VolumeIssuesDialog({
    Key? key,
    required this.issues,
    required this.volumeTitle,
  }) : super(key: key);

  @override
  State<VolumeIssuesDialog> createState() => _VolumeIssuesDialogState();
}

class _VolumeIssuesDialogState extends State<VolumeIssuesDialog> {
  int _selectedIssueIndex = 0;

  @override
  Widget build(BuildContext context) {
    final selectedIssue = widget.issues[_selectedIssueIndex];

    return Dialog(
      child: SizedBox(
        width: 700,
        height: 500,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // 📚 Lista de issues
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.volumeTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: widget.issues.length,
                            itemBuilder: (context, index) {
                              final issue = widget.issues[index];
                              final title = issue['name'] ?? 'Sin título';
                              final number = issue['issue_number'] ?? '?';
                              return ListTile(
                                title: Text('$title'),
                                subtitle: Text('Issue #$number'),
                                selected: index == _selectedIssueIndex,
                                onTap: () async {
                                  setState(() {
                                    _selectedIssueIndex = index;
                                  });
                                  final data = await getIssuesForVolume(
                                    issue['id'],
                                  );
                                  print(data);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(),
                  // 🖼️ Detalles e imagen del issue
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título y número
                          Text(
                            selectedIssue['name'] ?? 'Sin título',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Issue #${selectedIssue['issue_number'] ?? '?'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Fecha de publicación
                          Text(
                            'Publicado: ${selectedIssue['cover_date'] ?? 'Fecha desconocida'}',
                          ),
                          const SizedBox(height: 16),
                          // Imagen
                          Expanded(
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: 2 / 3,
                                child: FutureBuilder<Uint8List>(
                                  future: CommonServices.getProxyImageBytes(
                                    selectedIssue['image']['small_url'],
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.contain,
                                      );
                                    } else if (snapshot.hasError) {
                                      return const Icon(Icons.error);
                                    }
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🟩 Botón al final del diálogo
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(selectedIssue);
                  },
                  child: const Text('Seleccionar cómic'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> getIssuesForVolume(int issueId) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('id');
  final searchResults = await ComicServices.getIssueInfo(userId ?? 0, issueId);

  //print(searchResults);
  return searchResults;
}
