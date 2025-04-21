import 'package:flutter/material.dart';

import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _apiKeyController = TextEditingController();
  double sliderItemSizeValue = 5;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  @override
  void didUpdateWidget(covariant PreferencesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadPreferences(); // Vuelve a cargar preferencias cuando el widget se actualiza
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      //sliderItemSizeValue = 7;
      //sliderItemSizeValue = prefs.getDouble("defaultGridItemSize") ?? 7;
      final rawValue = prefs.get("defaultGridItemSize");

      if (rawValue is double) {
        sliderItemSizeValue = rawValue;
      } else if (rawValue is String) {
        sliderItemSizeValue = double.tryParse(rawValue) ?? 7.0;
      } else {
        sliderItemSizeValue = 7.0;
      }
      _apiKeyController.text = prefs.getString("Comicvine Key") ?? '';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("id");

    final settings = [
      {
        'userId': userId,
        'key': 'Comicvine Key',
        'value': _apiKeyController.text.trim(),
      },
      {
        'userId': userId,
        'key': 'defaultGridItemSize',
        'value': sliderItemSizeValue
            .toString(), // Convierte a String si tu backend espera strings
      },
    ];

    final res = await CommonServices.saveMultipleSettingsToSharedPrefs(
      prefs,
      settings,
    );

    // Guardar también en local
    await prefs.setString("Comicvine Key", _apiKeyController.text.trim());
    await prefs.setDouble("defaultGridItemSize", sliderItemSizeValue);

    if (res.statusCode == 200) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          AppLocalizations.of(context)!.preferencesSaved,
          Colors.green,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 🟩 Primera columna: preferencias
            Expanded(
              flex: 2,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tamaño de elementos en la parrilla",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: sliderItemSizeValue,
                      min: 5,
                      max: 10,
                      divisions: 5,
                      label: sliderItemSizeValue.round().toString(),
                      onChanged: (value) =>
                          setState(() => sliderItemSizeValue = value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Comicvine API Key',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      onPressed: _savePreferences,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 24), // 🧱 Espacio entre columnas
            // 🟦 Segunda columna: para contenido adicional
            Expanded(
              flex: 3,
              child: Container(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }
}
