import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Asegúrate de tener este paquete
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
  final TextEditingController _backgroundImageController = TextEditingController();

  double sliderItemSizeValue = 5;
  Color themeColor = Colors.blue; // 🎨 Nuevo campo para color

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final rawValue = prefs.get("defaultGridItemSize");

      if (rawValue is double) {
        sliderItemSizeValue = rawValue;
      } else if (rawValue is String) {
        sliderItemSizeValue = double.tryParse(rawValue) ?? 7.0;
      } else {
        sliderItemSizeValue = 7.0;
      }

      _apiKeyController.text = prefs.getString("Comicvine Key") ?? '';
      _backgroundImageController.text = prefs.getString("backgroundImagePath") ?? '';
      int? colorValue = prefs.getInt("themeColor");
      if (colorValue != null) themeColor = Color(colorValue);
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
        'value': sliderItemSizeValue.toString(),
      },
      {
        'userId': userId,
        'key': 'backgroundImagePath',
        'value': _backgroundImageController.text.trim(),
      },
      {
        'userId': userId,
        'key': 'themeColor',
        'value': themeColor.value.toString(),
      },
    ];

    final res = await CommonServices.saveMultipleSettingsToSharedPrefs(
      prefs,
      settings,
    );

    await prefs.setString("Comicvine Key", _apiKeyController.text.trim());
    await prefs.setDouble("defaultGridItemSize", sliderItemSizeValue);
    await prefs.setString("backgroundImagePath", _backgroundImageController.text.trim());
    await prefs.setInt("themeColor", themeColor.value);

    if (res.statusCode == 200 && context.mounted) {
      CustomSnackBar.show(
        context,
        AppLocalizations.of(context)!.preferencesSaved,
        Colors.green,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _pickThemeColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar color de tema'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: themeColor,
              onColorChanged: (color) => setState(() => themeColor = color),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
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
                      onChanged: (value) => setState(() => sliderItemSizeValue = value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Comicvine API Key',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _backgroundImageController,
                      decoration: const InputDecoration(
                        labelText: 'Ruta de imagen de fondo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text("Color de tema: "),
                        GestureDetector(
                          onTap: _pickThemeColor,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: themeColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
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
            const SizedBox(width: 24),
            Expanded(flex: 3, child: Container(padding: const EdgeInsets.all(16))),
          ],
        ),
      ),
    );
  }
}
