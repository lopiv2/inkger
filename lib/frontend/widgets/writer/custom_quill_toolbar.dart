// document_editor_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CustomQuillToolbar extends StatelessWidget {
  final QuillController controller;

  const CustomQuillToolbar({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color iconColor = const Color.fromARGB(255, 216, 216, 216);
    Color disabledColor = Colors.grey[600] ?? Colors.grey;
    if (Theme.of(context).brightness == Brightness.dark) {
      iconColor = Colors.white;
      disabledColor = Colors.grey[800] ?? Colors.grey;
    }
    return QuillSimpleToolbar(
      controller: controller,
      config: QuillSimpleToolbarConfig(
        color: Colors.grey[850],
        sectionDividerColor: Colors.white,
        buttonOptions: QuillSimpleToolbarButtonOptions(
          undoHistory: QuillToolbarHistoryButtonOptions(
            iconTheme: QuillIconTheme(
              iconButtonUnselectedData: IconButtonData(
                color: iconColor,
                hoverColor: Colors.blueGrey,
              ),
            ),
          ),
          redoHistory: QuillToolbarHistoryButtonOptions(
            iconTheme: QuillIconTheme(
              iconButtonUnselectedData: IconButtonData(
                color: iconColor,
                hoverColor: Colors.blueGrey,
                disabledColor: disabledColor,
              ),
            ),
          ),
          fontFamily: QuillToolbarFontFamilyButtonOptions(
            iconTheme: QuillIconTheme(
              iconButtonUnselectedData: IconButtonData(
                color: iconColor,
                hoverColor: Colors.blueGrey,
              ),
            ),
            style: TextStyle(color: iconColor),
          ),
          fontSize: QuillToolbarFontSizeButtonOptions(
            style: TextStyle(color: iconColor),
          ),
          selectHeaderStyleButtons: QuillToolbarSelectHeaderStyleButtonsOptions(iconTheme: QuillIconTheme(
            iconButtonUnselectedData: IconButtonData(
              color: iconColor,
              hoverColor: Colors.blueGrey,
            ),
          )),
          selectHeaderStyleDropdownButton: QuillToolbarSelectHeaderStyleDropdownButtonOptions(
            iconTheme: QuillIconTheme(
              iconButtonUnselectedData: IconButtonData(
                color: iconColor,
                hoverColor: Colors.blueGrey,
              ),
            ),
            textStyle: TextStyle(color: iconColor),
          ),
          base: QuillToolbarBaseButtonOptions(
            iconTheme: QuillIconTheme(
              iconButtonUnselectedData: IconButtonData(
                color: iconColor,
                hoverColor: Colors.blueGrey,
                disabledColor: disabledColor,
              ),
            ),
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
        showClipboardCopy: true,
        showClipboardPaste: true, 
        showClipboardCut: true,
      ),
    );
  }
}
