import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/app_preferences.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:provider/provider.dart';

class CentralContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prefsProvider = context.watch<PreferencesProvider>();
    final prefs = prefsProvider.preferences;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón para mostrar preferencias en consola
          ElevatedButton(
            onPressed: () {
              _logPreferences(prefs);
            },
            child: const Text("Mostrar Prefs en Consola"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Botón para mostrar preferencias en diálogo
          ElevatedButton(
            onPressed: () {
              _showPreferencesDialog(context, prefs);
            },
            child: const Text("Mostrar Prefs en Diálogo"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Visualización directa de algunas prefs
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPreferenceRow('Modo oscuro', prefs.darkMode.toString()),
                  _buildPreferenceRow('Idioma', prefs.languageCode),
                  _buildPreferenceRow('Directorio Cómics', prefs.comicAppDirectory ?? 'No configurado'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logPreferences(AppPreferences prefs) {
    debugPrint('═════════ Preferencias Actuales ═════════');
    debugPrint('• Modo oscuro: ${prefs.darkMode}');
    debugPrint('• Idioma: ${prefs.languageCode}');
    debugPrint('• Tamaño texto: ${prefs.textScaleFactor}');
    debugPrint('• Notificaciones: ${prefs.notificationsEnabled}');
    debugPrint('• Dir. Cómics: ${prefs.comicAppDirectory ?? "NULL"}');
    debugPrint('• Dir. Libros: ${prefs.bookAppDirectory ?? "NULL"}');
    debugPrint('• Dir. Audiolibros: ${prefs.audiobookAppDirectory ?? "NULL"}');
    debugPrint('═════════════════════════════════════════');
  }

  void _showPreferencesDialog(BuildContext context, AppPreferences prefs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preferencias Actuales'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogRow(context, 'Modo oscuro', prefs.darkMode.toString()),
              _buildDialogRow(context, 'Idioma', prefs.languageCode),
              _buildDialogRow(context, 'Tamaño texto', prefs.textScaleFactor.toString()),
              _buildDialogRow(context, 'Notificaciones', prefs.notificationsEnabled.toString()),
              const Divider(),
              _buildDialogRow(context, 'Dir. Cómics', prefs.comicAppDirectory ?? 'No configurado'),
              _buildDialogRow(context, 'Dir. Libros', prefs.bookAppDirectory ?? 'No configurado'),
              _buildDialogRow(context, 'Dir. Audiolibros', prefs.audiobookAppDirectory ?? 'No configurado'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDialogRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}