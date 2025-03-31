import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/epub_book.dart';
import 'package:inkger/frontend/screens/epub_reader_screen.dart';
import 'package:inkger/frontend/screens/epub_reader_screen2.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xml/xml.dart' as xml;

Future<EpubBook> parseEpub(Uint8List epubData, String coverPath) async {
  try {
    // Decodificar el archivo EPUB
    final archive = ZipDecoder().decodeBytes(epubData);

    // Buscar el archivo container.xml
    final containerFile = archive.files.firstWhere(
      (file) => file.name.contains('META-INF/container.xml'),
      orElse: () => throw Exception('No se encontró el archivo container.xml'),
    );

    final containerXml = xml.XmlDocument.parse(
      utf8.decode(containerFile.content as List<int>),
    );

    // Obtener la ruta del archivo OPF
    final rootfile = containerXml
        .findAllElements('rootfile')
        .firstWhere((node) => node.name.local == 'rootfile');
    final opfPath = rootfile.getAttribute('full-path')!;

    // Parsear el archivo OPF
    final opfFile = archive.files.firstWhere(
      (file) => file.name.contains(opfPath),
    );

    final opfXml = xml.XmlDocument.parse(
      utf8.decode(opfFile.content as List<int>),
    );

    // Obtener el título del libro
    final titleElement = opfXml
        .findAllElements('title')
        .firstWhere((node) => node.name.local == 'title');
    final title = titleElement.text ?? 'Sin título';

    // Extraer los capítulos
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
                orElse:
                    () =>
                        throw Exception(
                          'No se encontró el archivo del capítulo ${item['href']}',
                        ),
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
      coverImagePath: coverPath,
    );
  } catch (e) {
    throw Exception('Error al procesar el archivo EPUB: $e');
  }
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

Future<void> loadBookFile(BuildContext context, String bookId) async {
  try {
    final response = await BookServices.getBookFile(bookId);
    if (response.statusCode == 200) {
      final bookData = json.decode(response.data);
      String filePath = bookData['filePath'];
      print(filePath);
      /*final bookData = response.data as Uint8List;
      print(bookData);*/
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              /*(context) => CustomEpubReader(
                epubData: bookData, // Enviar los bytes del archivo EPUB
                coverPath: 'path_to_cover_image',
              ),*/
              (context) => EpubReaderScreen(epubPath: "/ruta/al/libro.epub"),
        ),
      );
    } else {
      debugPrint('Error al cargar el archivo del libro');
    }
  } catch (e) {
    debugPrint('Error cargando el libro: $e');
  }
}
