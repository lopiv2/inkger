import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConvertEbookOptionsDialog extends StatefulWidget {
  final int ebookId;

  const ConvertEbookOptionsDialog({Key? key, required this.ebookId})
    : super(key: key);

  @override
  State<ConvertEbookOptionsDialog> createState() =>
      _ConvertEbookOptionsDialogState();
}

class _ConvertEbookOptionsDialogState extends State<ConvertEbookOptionsDialog> {
  bool _isConverting = false;

  @override
  Widget build(BuildContext context) {
    final providerBooks = Provider.of<BooksProvider>(context, listen: false);
    return AlertDialog(
      title: const Text('Convertir archivo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              if (!mounted) return;
              final prefs = await SharedPreferences.getInstance();
              final id = prefs.getInt('id');
              await BookServices.convertToFormat(widget.ebookId, 'epub');
              if (!mounted) return;
              await providerBooks.loadBooks(id ?? 0);
              CustomSnackBar.show(
                context,
                'Conversión a EPUB exitosa',
                Colors.green,
                duration: Duration(seconds: 4),
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.book),
            label: const Text('Convertir a EPUB'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (!mounted) return;
              final prefs = await SharedPreferences.getInstance();
              final id = prefs.getInt('id');
              await BookServices.convertToFormat(widget.ebookId, 'azw3');
              if (!mounted) return;
              await providerBooks.loadBooks(id ?? 0);
              CustomSnackBar.show(
                context,
                'Conversión a AZW3 exitosa',
                Colors.green,
                duration: Duration(seconds: 4),
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.book),
            label: const Text('Convertir a AZW3'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                if (!mounted) return;
                final prefs = await SharedPreferences.getInstance();
                final id = prefs.getInt('id');
                await BookServices.convertToFormat(widget.ebookId, 'mobi');
                if (!mounted) return;
                await providerBooks.loadBooks(id ?? 0);
                CustomSnackBar.show(
                  context,
                  'Conversión a MOBI exitosa',
                  Colors.green,
                  duration: Duration(seconds: 4),
                );
                Navigator.of(context).pop();
              } catch (e) {
                if (mounted) {
                  CustomSnackBar.show(
                    context,
                    'Error al convertir a MOBI: $e',
                    Colors.red,
                    duration: Duration(seconds: 4),
                  );
                }
              }
            },
            icon: const Icon(Icons.book_online),
            label: const Text('Convertir a MOBI'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isConverting
                ? null
                : () async {
                    if (!mounted) return;
                    setState(() => _isConverting = true);
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final id = prefs.getInt('id');
                      await BookServices.convertToFormat(widget.ebookId, 'pdf');
                      if (!mounted) return;
                      await providerBooks.loadBooks(id ?? 0);
                      CustomSnackBar.show(
                        context,
                        'Conversión a PDF exitosa',
                        Colors.green,
                        duration: Duration(seconds: 4),
                      );
                      Navigator.of(context).pop();
                    } finally {
                      if (mounted) {
                        setState(() => _isConverting = false);
                      }
                    }
                  },
            icon: _isConverting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomLoader(size: 60.0, color: Colors.blue),
                  )
                : const Icon(Icons.picture_as_pdf),
            label: _isConverting
                ? const Text('Convirtiendo...')
                : const Text('Convertir a PDF'),
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
    _isConverting = false;
    super.dispose();
  }
}
