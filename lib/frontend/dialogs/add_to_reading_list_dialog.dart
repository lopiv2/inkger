import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/reading_list_services.dart';
import '../utils/reading_list_provider.dart';

class AddToReadingListDialog extends StatefulWidget {
  final int id;
  final String type;
  final String? series;
  final String? title;
  final String? coverUrl; 

  const AddToReadingListDialog({Key? key, required this.id, required this.type, this.series, this.title, this.coverUrl}) : super(key: key);

  @override
  State<AddToReadingListDialog> createState() => _AddToReadingListDialogState();
}

class _AddToReadingListDialogState extends State<AddToReadingListDialog> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLists();
    });
  }

  Future<void> _loadLists() async {
    final lists = await context.read<ReadingListProvider>().fetchReadingLists();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar lista de lectura'),
      content: Consumer<ReadingListProvider>(
        builder: (context, provider, child) {
          final readingLists = provider.lists;
          if (readingLists.isEmpty) {
            return const Text('No hay listas de lectura disponibles.');
          }
          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: readingLists.length,
              itemBuilder: (context, index) {
                final list = readingLists[index];
                return ListTile(
                  title: Text(list.title),
                  onTap: () async {
                    try {
                      await ReadingListServices.addItemToList(
                        int.parse(list.id!),
                        widget.id,
                        widget.type,
                        widget.title ?? '',
                        widget.series ?? '',
                        widget.coverUrl ?? '',
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Elemento añadido a la lista "${list.title}"',
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al añadir el elemento: $e'),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}