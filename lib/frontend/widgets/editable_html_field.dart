import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class EditableHtmlField extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  EditableHtmlField({required this.label, required this.controller});

  @override
  _EditableHtmlFieldState createState() => _EditableHtmlFieldState();
}

class _EditableHtmlFieldState extends State<EditableHtmlField> {
  bool _containsHtml = false;

  @override
  void initState() {
    super.initState();
    // Verifica si el contenido inicial contiene HTML
    _containsHtml = _containsHtmlContent(widget.controller.text);
  }

  // Función para verificar si el texto contiene HTML
  bool _containsHtmlContent(String text) {
    final htmlRegex = RegExp(r"<[^>]+>");
    return htmlRegex.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: _containsHtml
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HtmlWidget(
                  widget.controller.text,
                  textStyle: TextStyle(fontSize: 16), // Personaliza el estilo del texto
                  /*onTapUrl: (url) {
                    print("URL clicked: $url");
                  },*/
                ),
                SizedBox(height: 8),
                TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    labelText: widget.label,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    setState(() {
                      _containsHtml = _containsHtmlContent(text);
                    });
                  },
                ),
              ],
            )
          : TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                labelText: widget.label,
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                setState(() {
                  _containsHtml = _containsHtmlContent(text);
                });
              },
            ),
    );
  }
}
