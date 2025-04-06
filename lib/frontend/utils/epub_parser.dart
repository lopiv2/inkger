import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:inkger/frontend/models/epub_book.dart';
import 'package:xml/xml.dart';

class EpubParser {
  /// Descomprime el archivo EPUB y extrae los archivos HTML y toc.ncx
  static Map<String, dynamic> extractEpubContent(Uint8List epubBytes) {
    final archive = ZipDecoder().decodeBytes(epubBytes);
    final content = <String, dynamic>{};

    for (final file in archive.files) {
      if (file.isFile && !file.name.endsWith('/')) {
        try {
          // Para archivos de texto (HTML, CSS, NCX, etc.)
          if (file.name.endsWith('.html') ||
              file.name.endsWith('.xhtml') ||
              file.name.endsWith('.ncx') ||
              file.name.endsWith('.css') ||
              file.name.endsWith('.opf')) {
            content[file.name] = utf8.decode(file.content);
          }
          // Para imágenes y otros binarios
          else {
            content[file.name] = file.content;
          }
        } catch (e) {
          print('Error procesando archivo ${file.name}: $e');
        }
      }
    }

    return content;
  }

  /// Parsear toc.ncx y extraer los puntos de navegación (navPoints)
  static List<NavPoint> parseNavigationPoints(String tocContent) {
    try {
      final document = XmlDocument.parse(tocContent);
      final navMap = document.findAllElements('navMap').firstOrNull;

      if (navMap == null) return [];

      final navPoints = _parseNavPoints(navMap);

      // Ordenar recursivamente toda la estructura
      return _sortNavPoints(navPoints);
    } catch (e) {
      print('Error parsing NCX: $e');
      return [];
    }
  }

  /// Función recursiva para extraer navPoints
  /// Parsea los NavPoints respetando el orden del documento para los hermanos.
  static List<NavPoint> _parseNavPoints(XmlElement element) {
    return element.children
        .whereType<XmlElement>() // Filtrar solo elementos XML
        .where((e) => e.name.local == 'navPoint') // Filtrar solo los <navPoint>
        .map((navPointElement) {

          final id = navPointElement.getAttribute('id') ?? '';

          // Manejo seguro de playOrder
          final playOrderStr = navPointElement.getAttribute('playOrder') ?? '';
          // Se asigna 0 si playOrder falta o no es un número válido
          final playOrder = int.tryParse(playOrderStr) ?? 0;

          // Búsqueda segura de navLabel (usando descendants dentro de navPointElement está bien)
          final navLabel = navPointElement.descendants
              .whereType<XmlElement>()
              .firstWhere(
                (e) => e.name.local == 'navLabel',
                // Devuelve un elemento vacío si no se encuentra para evitar null errors
                orElse: () => XmlElement(XmlName('navLabel')),
              );

          // Búsqueda segura de text dentro de navLabel
          final label =
              navLabel.descendants
                  .whereType<XmlElement>()
                  .firstWhere(
                    (e) => e.name.local == 'text',
                    orElse:
                        () => XmlElement(XmlName('text')), // Evita null errors
                  )
                  .innerText; // Obtiene el texto interno

          // Búsqueda segura de content/src (usando descendants dentro de navPointElement está bien)
          final contentSrc =
              navPointElement.descendants
                  .whereType<XmlElement>()
                  .firstWhere(
                    (e) => e.name.local == 'content',
                    orElse:
                        () =>
                            XmlElement(XmlName('content')), // Evita null errors
                  )
                  .getAttribute('src') ??
              ''; // Obtiene el 'src', default a '' si no existe

          final children = _parseNavPoints(navPointElement);

          // Crear y devolver el objeto NavPoint
          return NavPoint(
            id: id,
            label: label,
            contentSrc: contentSrc,
            playOrder: playOrder, // Se guarda el playOrder (o 0)
            children:
                children, // Se asignan los hijos encontrados recursivamente
          );
        })
        .toList(); // Convertir el resultado del mapeo en una lista
  }

  // Ordenar por playOrder
  static List<NavPoint> _sortNavPoints(List<NavPoint> navPoints) {
    // Ordenar el nivel actual
    navPoints.sort((a, b) => a.playOrder.compareTo(b.playOrder));

    // Ordenar recursivamente los hijos
    for (final navPoint in navPoints) {
      if (navPoint.children.isNotEmpty) {
        navPoint.children = _sortNavPoints(navPoint.children);
      }
    }

    return navPoints;
  }
}
