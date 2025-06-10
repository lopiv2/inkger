import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/reading_list_provider.dart'; // Make sure this path is correct

class AddToReadingListDialog extends StatefulWidget {
  // Remove individual comic properties, as this dialog now only selects the list.
  const AddToReadingListDialog({Key? key}) : super(key: key);

  @override
  State<AddToReadingListDialog> createState() => _AddToReadingListDialogState();
}

class _AddToReadingListDialogState extends State<AddToReadingListDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLists();
    });
  }

  Future<void> _loadLists() async {
    // Fetch lists, no change here
    await context.read<ReadingListProvider>().fetchReadingLists();
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
                  onTap: () {
                    // When a list is tapped, pop the dialog with the selected list's ID
                    Navigator.of(context).pop(list.id);
                  },
                );
              },
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Pop with null if cancelled
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}