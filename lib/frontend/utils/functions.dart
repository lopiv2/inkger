import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/epub_book.dart';
import 'package:inkger/frontend/screens/epub_reader_screen.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xml/xml.dart' as xml;

Future<EpubBook> parseEpub(String epubPath, String coverPath) async {
  final bytes = await File(epubPath).readAsBytes();
  final file = File(epubPath);
  if (await file.exists()) {
    print("El archivo existe y es accesible");
  } else {
    print("El archivo no se encontró o no es accesible");
  }
  final archive = ZipDecoder().decodeBytes(bytes);
  final String coverImagePath = coverPath;

  // Buscar container.xml
  final containerFile = archive.files.firstWhere(
    (file) => file.name.contains('META-INF/container.xml'),
  );

  final containerXml = xml.XmlDocument.parse(
    utf8.decode(containerFile.content as List<int>),
  );

  final rootfile = containerXml
      .findAllElements(
        '*',
        namespace: '*',
      ) // Busca sin importar el espacio de nombres
      .firstWhere((node) => node.name.local == 'rootfile');

  final opfPath = rootfile.getAttribute('full-path')!;

  // Parsear contenido OPF
  final opfFile = archive.files.firstWhere(
    (file) => file.name.contains(opfPath),
  );

  final opfXml = xml.XmlDocument.parse(
    utf8.decode(opfFile.content as List<int>),
  );

  final titleElement = opfXml
      .findAllElements('*', namespace: '*')
      .firstWhere((node) => node.name.local == 'title');

  final title = titleElement?.text ?? 'Sin título';

  // Extraer capítulos
  final manifestItems =
      opfXml
          .findAllElements('item')
          .map(
            (item) => {
              'id': item.getAttribute('id'),
              'href': item.getAttribute('href'),
              'type': item.getAttribute('media-type'),
            },
          )
          .toList();

  final chapters =
      manifestItems
          .where((item) => item['type'] == 'application/xhtml+xml')
          .map((item) {
            final chapterFile = archive.files.firstWhere(
              (file) => file.name.contains(item['href']!),
            );

            return EpubChapter(
              id: item['id']!,
              title: item['href']!.split('/').last,
              content: utf8.decode(chapterFile.content as List<int>),
            );
          })
          .toList();

  return EpubBook(
    title: title,
    chapters: chapters,
    coverImagePath: coverImagePath,
  );
}

Future<Color> getDominantColor(Uint8List? imageBytes) async {
  if (imageBytes == null) return Colors.grey;

  try {
    final palette = await PaletteGenerator.fromImageProvider(
      MemoryImage(imageBytes),
      size: Size(100, 100), // Tamaño reducido para mejor rendimiento
      maximumColorCount: 20,
    );
    return palette.dominantColor?.color ?? Colors.grey;
  } catch (e) {
    debugPrint('Error obteniendo color predominante: $e');
    return Colors.grey;
  }
}

void openEpubReader(BuildContext context, String epubPath, String coverPath) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) =>
              CustomEpubReader(epubPath: epubPath, coverPath: coverPath),
    ),
  );
}
