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

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKeyController.text = prefs.getString("Comicvine Key") ?? '';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("id");
    final body = {
      'userId': userId,
      'key': 'Comicvine Key',
      'value': _apiKeyController.text.trim(),
    };
    final res = await CommonServices.saveSettingsToSharedPrefs(prefs, body);

    if (res.statusCode == 200) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          AppLocalizations.of(context)!.preferencesSaved,
          Colors.green,
          duration: Duration(seconds: 4),
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
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
    );
  }
}
