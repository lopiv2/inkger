import 'package:flutter/material.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../utils/reading_list_provider.dart';
import '../services/reading_list_services.dart';

class CreateListDialog extends StatelessWidget {
  const CreateListDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return AlertDialog(
      title: const Text('Crear nueva lista'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Nombre de la lista'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () async {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              try {
                await ReadingListServices.createReadingList({'title': name});
                context.read<ReadingListProvider>().fetchReadingLists();
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al crear la lista: $e')),
                );
              }
            }
          },
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
