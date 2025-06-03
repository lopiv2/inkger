// document_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:inkger/frontend/widgets/writer/custom_quill_toolbar.dart';

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
        backgroundColor: Colors.grey[800],
        automaticallyImplyLeading: false,
        title: Center(child: Text(widget.documentTitle, style: const TextStyle(color: Colors.white))),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveDocument, color: const Color.fromARGB(255, 216, 216, 216),),
        ],
      ),
      body: Column(
        children: [
          Container(
            child: CustomQuillToolbar(controller: _controller),
          ),
          Expanded(
            child: Container(
              color: Colors.black45,
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
