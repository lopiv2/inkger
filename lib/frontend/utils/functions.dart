import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/services/comic_services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:inkger/frontend/models/epub_book.dart';
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
    final title = titleElement.text;

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

Future<void> calculateDominantColor(Uint8List imageBytes, bool mounted) async {
  final ValueNotifier<Color> _dominantColorNotifier = ValueNotifier<Color>(
    Colors.grey,
  ); // Color por defecto
  try {
    final color = await getDominantColor(imageBytes);
    if (mounted) {
      _dominantColorNotifier.value = color;
    }
  } catch (e) {
    debugPrint('Error calculando color: $e');
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

Future<void> loadBookFile(
  BuildContext context,
  String bookId,
  String title,
  int progress,
) async {
  try {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Obtener los bytes del EPUB
    final epubBytes = await BookServices.getBookFile(bookId);

    // Crear Blob moderno (sin dart:html)
    final blob = html.Blob([epubBytes]);
    final epubBytesBlob = await blobToUint8List(blob);

    // Cerrar el diálogo de carga usando el rootNavigator
    Navigator.of(context, rootNavigator: true).pop();

    // Navegar a la pantalla del lector
    context.go(
      '/ebook-reader/${bookId}', // bookId en la URL
      extra: {
        // Datos complejos como mapa
        'epubBytes': epubBytesBlob,
        'bookTitle': title,
        'initialProgress': progress,
        'bookId': bookId,
      },
    );
  } catch (e) {
    // Cerrar diálogo de carga en caso de error usando rootNavigator
    Navigator.of(context, rootNavigator: true).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al cargar el libro: ${e.toString()}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

Future<void> loadComicFile(
  BuildContext context,
  String comicId,
  String title,
  int progress,
) async {
  try {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Obtener los bytes del EPUB
    final epubBytes = await ComicServices.getcomicFile(comicId);

    // Crear Blob moderno (sin dart:html)
    final blob = html.Blob([epubBytes]);
    final epubBytesBlob = await blobToUint8List(blob);

    // Cerrar el diálogo de carga usando el rootNavigator
    Navigator.of(context, rootNavigator: true).pop();

    // Navegar a la pantalla del lector
    context.go(
      '/comic-reader/${comicId}', // bookId en la URL
      extra: {
        // Datos complejos como mapa
        'epubBytes': epubBytesBlob,
        'bookTitle': title,
        'initialProgress': progress,
        'bookId': comicId,
      },
    );
  } catch (e) {
    // Cerrar diálogo de carga en caso de error usando rootNavigator
    Navigator.of(context, rootNavigator: true).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al cargar el libro: ${e.toString()}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

Future<Uint8List> blobToUint8List(html.Blob blob) async {
  final reader = html.FileReader();
  reader.readAsArrayBuffer(blob);
  await reader.onLoad.first;
  return Uint8List.fromList(reader.result as List<int>);
}

Future<Uint8List> loadImage(String imagePath) async {
  final file = File(imagePath);
  if (await file.exists()) {
    return await file.readAsBytes();
  } else {
    throw Exception('Image file not found');
  }
}

List<String> parseCommaSeparatedList(dynamic data) {
  if (data == null) return [];

  if (data is List) {
    return data
        .expand((item) => item.toString().split(','))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  if (data is String) {
    return data
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  return [];
}
