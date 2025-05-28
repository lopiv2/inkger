import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/comic_services.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConvertOptionsDialog extends StatefulWidget {
  final int comicId;

  const ConvertOptionsDialog({Key? key, required this.comicId})
    : super(key: key);

  @override
  State<ConvertOptionsDialog> createState() => _ConvertOptionsDialogState();
}

class _ConvertOptionsDialogState extends State<ConvertOptionsDialog> {
  bool _isConverting = false;

  Future<void> _loadComics(BuildContext safeContext) async {
    try {
      final provider = Provider.of<ComicsProvider>(safeContext, listen: false);
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('id');
      await provider.loadcomics(id ?? 0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar cómics: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Convertir archivo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ComicServices.convertToCBR(widget.comicId);
            },
            icon: const Icon(Icons.file_present),
            label: const Text('Convertir a CBR'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed:
                _isConverting
                    ? null
                    : () async {
                      final currentContext =
                          context; // Guarda el contexto ANTES de pop()
                      //Navigator.of(currentContext).pop();

                      await ComicServices.convertToCBZ(
                        currentContext,
                        widget.comicId,
                      );
                      await _loadComics(
                        currentContext,
                      ); // Usa el contexto guardado
                      Navigator.of(currentContext).pop();
                    },
            icon:
                _isConverting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CustomLoader(size: 60.0, color: Colors.blue),
                    )
                    : const Icon(Icons.folder_zip),
            label:
                _isConverting
                    ? const Text('Convirtiendo...')
                    : const Text('Convertir a CBZ'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isConverting ? null : () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Cancelar cualquier operación pendiente
    _isConverting = false;
    super.dispose();
  }
}
