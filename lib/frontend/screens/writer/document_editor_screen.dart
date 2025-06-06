// document_editor_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/services/writer_services.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';
import 'package:inkger/frontend/widgets/writer/custom_quill_toolbar.dart';
import 'package:inkger/l10n/app_localizations.dart';

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
  bool _isLoading = true; // Nuevo estado para el loader

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();

    // Cargar el documento desde la base de datos
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      final documentData = await CommonServices.fetchDocument(
        widget.documentId,
      );
      final delta = Document.fromJson(jsonDecode(documentData));
      CustomSnackBar.show(
        context,
        AppLocalizations.of(context)!.documentLoaded,
        Colors.green,
        duration: Duration(seconds: 4),
      );
      setState(() {
        _controller.document = delta;
        _isLoading = false; // Oculta el loader al terminar
      });
      
    } catch (e) {
      print('Error al cargar el documento: $e');
      setState(() {
        _isLoading = false; // Oculta el loader también en error
      });
      CustomSnackBar.show(
        context,
        AppLocalizations.of(context)!.errorLoadingDocument,
        Colors.red,
        duration: Duration(seconds: 4),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[800],
          automaticallyImplyLeading: false,
          title: Center(
            child: Text(
              widget.documentTitle,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              CustomLoader(),
              Text(
                AppLocalizations.of(context)!.documentLoading,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            widget.documentTitle,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          // Botón de exportar con menú desplegable
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_upload, color: Color.fromARGB(255, 216, 216, 216)),
            tooltip: 'Exportar',
            onSelected: (value) async {
              if (value == 'word') {
                // TODO: Lógica para exportar a Word
                CustomSnackBar.show(
                  context,
                  'Exportar a Word no implementado',
                  Colors.orange,
                  duration: Duration(seconds: 2),
                );
              } else if (value == 'pdf') {
                // TODO: Lógica para exportar a PDF
                CustomSnackBar.show(
                  context,
                  'Exportar a PDF no implementado',
                  Colors.orange,
                  duration: Duration(seconds: 2),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'word',
                child: Row(
                  children: [
                    Icon(Icons.description, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Exportar a Word'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Exportar a PDF'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await WriterServices.saveDocument(
                _controller,
                widget.documentId,
                widget.documentTitle,
              );
              CustomSnackBar.show(
                context,
                AppLocalizations.of(context)!.documentSaved,
                Colors.green,
                duration: Duration(seconds: 4),
              );
            },
            color: const Color.fromARGB(255, 216, 216, 216),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(child: CustomQuillToolbar(controller: _controller)),
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
