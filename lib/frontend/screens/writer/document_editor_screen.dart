// document_editor_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/services/writer_services.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
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
      setState(() {
        _controller.document = delta;
      });
    } catch (e) {
      print('Error al cargar el documento: $e');
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
