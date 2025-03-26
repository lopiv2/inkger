import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/library_services.dart';

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
    _loadLibraryPath(); // Cargar la ruta cuando se inicializa el diálogo
  }

  Future<void> _loadLibraryPath() async {
    try {
      final path = await LibraryServices.loadLibraryPath(widget.libraryId);
      if (mounted) {
        setState(() {
          _pathController.text = path; // Asignar la ruta al TextField
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar la ruta: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
            await LibraryServices.updateLibraryPath(
              context,
              widget.libraryId,
              _pathController.text,
            ); // Actualizar la ruta en la API
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
