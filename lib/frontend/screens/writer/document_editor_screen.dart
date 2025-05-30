// document_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class DocumentEditorScreen extends StatefulWidget {
  final String documentId;
  final String documentTitle;

  const DocumentEditorScreen({
    super.key,
    required this.documentId,
    required this.documentTitle,
  });

  @override
  State<DocumentEditorScreen> createState() => _DocumentEditorScreenState();
}

class _DocumentEditorScreenState extends State<DocumentEditorScreen> {
  late QuillController _controller;

  @override
  void initState() {
    super.initState();
    // Documento vacío para comenzar
    _controller = QuillController.basic();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveDocument() {
    final json = _controller.document.toDelta().toJson();
    // Aquí llamarías a tu backend o servicio para guardar el documento en MySQL
    print('Guardando documento con ID: ${widget.documentId}');
    print('Contenido: $json');
    // Mostrar confirmación
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Documento guardado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentTitle),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveDocument),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.red,
            child: QuillSimpleToolbar(
              controller: _controller,
              config: QuillSimpleToolbarConfig(
                iconTheme: QuillIconTheme(
                  iconButtonUnselectedData: IconButtonData(
                    color: Colors.grey[400], // Color iconos no seleccionados
                    splashColor: Colors.white12,
                    hoverColor: Colors.white24,
                    highlightColor: Colors.white30,
                    disabledColor: Colors.grey[700],
                  ),
                  iconButtonSelectedData: IconButtonData(
                    color: Colors.amber[400], // Color iconos seleccionados
                    splashColor: Colors.amberAccent,
                    hoverColor: Colors.amber,
                    highlightColor: Colors.amber,
                    disabledColor: Colors.grey,
                  ),
                ),
                multiRowsDisplay: false,
                showAlignmentButtons: true,
                showFontFamily: true,
                showFontSize: true,
                showColorButton: true,
                showBackgroundColorButton: true,
                showCodeBlock: true,
                showQuote: true,
                showIndent: true,
                showListCheck: true,
              ),
            ),
          ),

          Expanded(
            child: Container(
              color: Colors.grey,
              child: QuillEditor(
                config: QuillEditorConfig(),
                controller: _controller,
                focusNode: FocusNode(),
                scrollController: ScrollController(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
