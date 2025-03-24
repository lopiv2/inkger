import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart'; // Para manejar JSON

class EditLibraryDialog extends StatefulWidget {
  final String libraryTitle;
  final String libraryId; // ID de la biblioteca

  const EditLibraryDialog({
    Key? key,
    required this.libraryTitle,
    required this.libraryId,
  }) : super(key: key);

  @override
  _EditLibraryDialogState createState() => _EditLibraryDialogState();
}

class _EditLibraryDialogState extends State<EditLibraryDialog> {
  String _selectedOption = 'General'; // Opción seleccionada por defecto
  late TextEditingController
  _pathController; // Controlador para el campo de ruta
  bool _isLoading = true; // Estado de carga

  @override
  void initState() {
    super.initState();
    _pathController = TextEditingController();
    _loadLibraryPath(); // Cargar la ruta de la biblioteca al iniciar
  }

  // Método para cargar la ruta de la biblioteca desde la API
  Future<void> _loadLibraryPath() async {
  try {
    //print('Making request to: ${ApiService.dio.options.baseUrl}/api/libraries/${widget.libraryId}/path');
    final response = await ApiService.dio.get(
      '/api/libraries/${widget.libraryId}/path',
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode == 200) {
      if (response.data is String && response.data.contains('<!DOCTYPE html>')) {
        throw Exception('El backend no está respondiendo correctamente');
      }

      final data = response.data as Map<String, dynamic>;
      setState(() {
        _pathController.text = data['path'] ?? '';
        _isLoading = false;
      });
    } else {
      throw Exception('Error ${response.statusCode}: ${response.statusMessage}');
    }
  } catch (e) {
    print('Error loading library path: ${e.toString()}');
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando ruta: ${e.toString()}')),
      );
    }
  }
}

  // Método para actualizar la ruta en la API y mostrar un SnackBar
  Future<void> _updateLibraryPath() async {
    try {
      setState(() => _isLoading = true);

      final newPath = _pathController.text;
      final prefsProvider = context.read<PreferencesProvider>();

      // 2. Actualizar en el backend
      final response = await ApiService.dio.put(
        '/api/libraries/${widget.libraryId}',
        data: jsonEncode({'path': newPath}),
      );

      if (response.statusCode == 200) {
        switch (widget.libraryId) {
          case 'comics':
            await prefsProvider.setComicDirectory(newPath);
            break;
          case 'books':
            await prefsProvider.setBookDirectory(newPath);
            break;
          case 'audiobooks':
            await prefsProvider.setAudiobookDirectory(newPath);
            break;
        }

        CustomSnackBar.show(
          context,
          'Ruta actualizada correctamente',
          Colors.green,
        );
        //if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      CustomSnackBar.show(
        context,
        'Error al actualizar: ${e.toString()}',
        Colors.red,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Biblioteca: ${widget.libraryTitle}'),
      content:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Mostrar spinner si está cargando
              : SizedBox(
                width:
                    MediaQuery.of(context).size.width *
                    0.3, // Ajusta el ancho del diálogo
                height:
                    MediaQuery.of(context).size.height *
                    0.3, // Ajusta el ancho del diálogo
                child: Row(
                  children: [
                    // Columna izquierda: Opciones (General, Opciones, Metadatos)
                    Expanded(
                      flex: 1,
                      child: ListView(
                        children: [
                          _buildOptionButton('General'),
                          _buildOptionButton('Opciones'),
                          _buildOptionButton('Metadatos'),
                        ],
                      ),
                    ),

                    // Barra de separación
                    VerticalDivider(color: Colors.grey, thickness: 1),

                    // Columna derecha: Contenido según la opción seleccionada
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: _buildContent(),
                      ),
                    ),
                  ],
                ),
              ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Cerrar el diálogo
          },
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            await _updateLibraryPath(); // Actualizar la ruta en la API
            Navigator.pop(context); // Cerrar el diálogo
          },
          child: Text('Guardar'),
        ),
      ],
    );
  }

  // Método para construir los botones de opciones
  Widget _buildOptionButton(String option) {
    return ListTile(
      title: Text(option),
      selected: _selectedOption == option,
      selectedTileColor: Colors.blue.withOpacity(0.1),
      onTap: () {
        setState(() {
          _selectedOption = option; // Actualizar la opción seleccionada
        });
      },
    );
  }

  // Método para construir el contenido según la opción seleccionada
  Widget _buildContent() {
    switch (_selectedOption) {
      case 'General':
        return _buildGeneralContent();
      case 'Opciones':
        return _buildOptionsContent();
      case 'Metadatos':
        return _buildMetadataContent();
      default:
        return Container(); // Por defecto, no mostrar nada
    }
  }

  // Contenido para la opción "General"
  Widget _buildGeneralContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración General',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _pathController, // Controlador para la ruta
          decoration: InputDecoration(
            labelText: 'Ruta de la biblioteca',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // Contenido para la opción "Opciones"
  Widget _buildOptionsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opciones Avanzadas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        SwitchListTile(
          title: Text('Habilitar sincronización automática'),
          value: true,
          onChanged: (value) {
            // Lógica para cambiar el estado del switch
          },
        ),
        SwitchListTile(
          title: Text('Notificaciones de actualización'),
          value: false,
          onChanged: (value) {
            // Lógica para cambiar el estado del switch
          },
        ),
      ],
    );
  }

  // Contenido para la opción "Metadatos"
  Widget _buildMetadataContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión de Metadatos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Text('Aquí puedes gestionar los metadatos de la biblioteca.'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Lógica para actualizar metadatos
          },
          child: Text('Actualizar Metadatos'),
        ),
      ],
    );
  }
}
