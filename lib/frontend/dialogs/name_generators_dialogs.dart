import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inkger/frontend/models/name_generator.dart';
import 'package:inkger/frontend/services/writer_services.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';

class NameGeneratorsDialog extends StatefulWidget {
  final NameGenerator generator;
  final List<GeneratorSection> sections;

  const NameGeneratorsDialog({
    super.key,
    required this.generator,
    required this.sections,
  });

  @override
  State<NameGeneratorsDialog> createState() => _NameGeneratorsDialogState();
}

class _NameGeneratorsDialogState extends State<NameGeneratorsDialog> {
  late String selectedSection;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    selectedSection = widget.sections[0].title;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 650,
        height: 400,
        child: Row(
          children: [
            // Columna izquierda
            Container(
              width: 180,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  hoverColor: Colors.blueGrey, // Color al pasar el ratón
                  splashColor: Colors.grey[400],
                  child: ListView(
                    children:
                        widget.sections.map((section) {
                          final isSelected = section == selectedSection;
                          return ListTile(
                            leading: Icon(section.icon, color: Colors.white),
                            tileColor:
                                isSelected
                                    ? Colors.grey[800]
                                    : null, // Usa tileColor
                            title: Text(
                              section.title,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onTap: () {
                              setState(() {
                                selectedSection = section.title;
                              });
                            },
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),

            // Columna derecha
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                //child: _buildSectionContent(),
                child: SectionWithDropdown(selectedSection: selectedSection),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionWithDropdown extends StatefulWidget {
  final String selectedSection;

  const SectionWithDropdown({super.key, required this.selectedSection});

  @override
  _SectionWithDropdownState createState() => _SectionWithDropdownState();
}

class _SectionWithDropdownState extends State<SectionWithDropdown> {
  String? selectedType = 'Markov'; // Valor predeterminado del desplegable
  List<String> itemList = []; // Lista de elementos a mostrar
  TextEditingController itemController = TextEditingController();
  late TextEditingController _textController;
  final ScrollController _scrollController = ScrollController();
  String? selectedItem;

  void initState() {
    super.initState();
    // Inicializa el controlador de texto con el valor recibido
    _textController = TextEditingController(text: '');
  }

  // Función para abrir el dialogo con el valor del desplegable
  void openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 400),
            child: FutureBuilder<String>(
              // Usamos FutureBuilder para obtener los datos
              future: WriterServices.getDataGenerator(
                selectedType!,
                widget.selectedSection, // Asegúrate de pasar ambos parámetros
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  ); // Muestra un loading mientras esperas la respuesta
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  ); // Manejo de errores
                }

                if (snapshot.hasData) {
                  String data = snapshot.data!; // Los datos obtenidos de la API

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility:
                              true, // Para mostrar siempre la barra de scroll
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _textController..text = data,
                                maxLines: null, // Permite líneas ilimitadas
                                decoration: InputDecoration(
                                  labelText: 'Editar plantilla',
                                  floatingLabelAlignment:
                                      FloatingLabelAlignment.center,
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.multiline,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancelar"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await WriterServices.saveDataGenerator(
                                  selectedType!,
                                  widget.selectedSection,
                                  _textController.text,
                                );
                                CustomSnackBar.show(
                                  context,
                                  'Archivo editado correctamente',
                                  Colors.green,
                                  duration: Duration(seconds: 4),
                                );
                                Navigator.pop(
                                  context,
                                ); // Cierra el diálogo al guardar
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error al guardar: $e'),
                                  ),
                                );
                              }
                            },
                            child: const Text("Guardar"),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: Text("No data available"),
                  ); // Si no hay datos
                }
              },
            ),
          ),
        );
      },
    );
  }

  // Función para agregar elementos a la lista
  void addItem() {
    if (itemController.text.isNotEmpty) {
      setState(() {
        itemList.add(itemController.text);
        itemController.clear(); // Limpiar el campo después de agregar
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Text(
            'Generación de nombres de ${widget.selectedSection}',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 16),

          // Desplegable (Dropdown)
          Row(
            children: [
              Text('Tipo: '),
              DropdownButton<String>(
                dropdownColor: Colors.grey,
                value: selectedType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue;
                  });
                },
                items:
                    <String>['Markov', 'Affix'].map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
              ),
              Spacer(),
              IconButton(
                onPressed: () => openDialog(context),
                icon: Icon(Icons.edit),
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),

          SizedBox(height: 16),

          // Campo de lista de elementos (uno por línea)
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  final name = itemList[index];
                  final isSelected = selectedItem == name;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      // Efecto hover y ripple
                      hoverColor: Colors.blueGrey, // Color al pasar el ratón
                      splashColor: Colors.grey[400], // Efecto al tocar
                      onTap: () {
                        setState(() {
                          selectedItem = isSelected ? null : name;
                          if (!isSelected) {
                            Clipboard.setData(ClipboardData(text: name));
                            CustomSnackBar.show(
                              context,
                              "Copiado: $name",
                              Colors.green,
                              duration: Duration(seconds: 4),
                            );
                          }
                        });
                      },
                      child: ListTile(
                        tileColor:
                            isSelected
                                ? Colors.grey[800]
                                : null, // Usa tileColor
                        title: Text(
                          name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        // Añade espacio adicional y feedback visual
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        visualDensity: VisualDensity.comfortable,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final names = await WriterServices.fetchGeneratedNames(
                type: selectedType ?? '',
                generator: widget.selectedSection,
                number: 20,
              );
              setState(() {
                itemList = names;
              });
            },
            child: Text('Generar nombres'),
          ),
        ],
      ),
    );
  }
}
