import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/models/comic.dart';
import 'package:inkger/frontend/services/comic_services.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VolumeIssuesDialog extends StatefulWidget {
  final List<Map<String, dynamic>> issues;
  final String volumeTitle;
  final String publisher;
  final Comic comic;

  const VolumeIssuesDialog({
    Key? key,
    required this.issues,
    required this.volumeTitle,
    required this.comic,
    required this.publisher,
  }) : super(key: key);

  @override
  State<VolumeIssuesDialog> createState() => _VolumeIssuesDialogState();
}

class _VolumeIssuesDialogState extends State<VolumeIssuesDialog> {
  int _selectedIssueIndex = 0;
  late Map<String, dynamic> selectedIssueData;

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
                                  selectedIssueData = await getIssuesForVolume(
                                    issue['id'],
                                  );
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
                  onPressed: () async {
                    final currentContext = context;

                    await sendSelectedComicToBackend(
                      selectedIssueData,
                      currentContext,
                      widget.comic,
                      widget.volumeTitle,
                      widget.publisher,
                    );

                    if (!context.mounted) return;

                    final prefs = await SharedPreferences.getInstance();
                    final provider = Provider.of<ComicsProvider>(
                      context,
                      listen: false,
                    );
                    await provider.loadcomics(prefs.getInt('id') ?? 0);

                    // 2) Cierra **ambos** dialogs con Navigator.pop
                    if (Navigator.of(context).canPop())
                      Navigator.of(context).pop(); // cierra IssueDialog
                    if (Navigator.of(context).canPop())
                      Navigator.of(context).pop(); // cierra MetadataDialog

                    // Ahora redirigimos con go_router
                    context.go('/comics');
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

Future<void> sendSelectedComicToBackend(
  Map<String, dynamic> selectedIssue,
  BuildContext context,
  Comic comic,
  String volumeTitle,
  String publisher,
) async {
  final searchResults = await ComicServices.sendDataComicToSave(
    selectedIssue,
    context,
    comic,
    volumeTitle,
    publisher,
  );
}

Future<Map<String, dynamic>> getIssuesForVolume(int issueId) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('id');
  final searchResults = await ComicServices.getIssueInfo(userId ?? 0, issueId);

  //print(prettifyJson(searchResults));
  return searchResults;
}
