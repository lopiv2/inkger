import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:go_router/go_router.dart';
import 'package:html/parser.dart' show parse;
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:inkger/frontend/models/epub_book.dart';
import 'package:inkger/frontend/services/book_services.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/utils/epub_parser.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class CustomReaderEpub extends StatefulWidget {
  final Uint8List epubBytes;
  final String bookTitle;
  final int initialProgress;
  final int bookId;

  const CustomReaderEpub({
    Key? key,
    required this.epubBytes,
    required this.bookTitle,
    required this.initialProgress,
    required this.bookId,
  }) : super(key: key);

  @override
  _CustomReaderEpubState createState() => _CustomReaderEpubState();
}

class _CustomReaderEpubState extends State<CustomReaderEpub>
    with FullScreenListener {
  late Map<String, dynamic> epubContent;
  late List<NavPoint> navPoints;
  int currentNavIndex = 0;
  bool isLoading = true;
  String? errorMessage;
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _loadEpubContent();
    FullScreen.addListener(this);
    currentNavIndex =
        ((widget.initialProgress / 100) * navPoints.length).round();
  }

  @override
  void dispose() {
    FullScreen.removeListener(this);
    super.dispose();
  }

  @override
  void onFullScreenChanged(bool enabled, SystemUiMode? systemUiMode) {
    setState(() {
      isFullScreen = enabled;
    });
  }

  void disableFullScreenFalse() async {
    Provider.of<PreferencesProvider>(
      context,
      listen: false,
    ).toggleFullScreenMode(false);
    FullScreen.setFullScreen(false);
  }

  void _toggleFullScreen() async {
    if (isFullScreen == false) {
      Provider.of<PreferencesProvider>(
        context,
        listen: false,
      ).toggleFullScreenMode(true);
      FullScreen.setFullScreen(true);
    } else {
      Provider.of<PreferencesProvider>(
        context,
        listen: false,
      ).toggleFullScreenMode(false);
      FullScreen.setFullScreen(false);
    }
  }

  Future<void> _saveProgress() async {
    int progress = ((currentNavIndex / navPoints.length) * 100).round();

    await BookServices.saveReadingProgress(widget.bookId, progress, context);
    context.go('/home');
  }

  Future<void> _loadEpubContent() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // 1. Extraer contenido del EPUB
      epubContent = EpubParser.extractEpubContent(widget.epubBytes);

      // 2. Buscar archivo de navegación (puede ser .ncx o .xhtml)
      final tocContent = _findTocContent();
      if (tocContent == null) {
        throw Exception('No se encontró tabla de contenidos');
      }

      // 3. Parsear puntos de navegación
      navPoints = EpubParser.parseNavigationPoints(tocContent);
      if (navPoints.isEmpty) {
        throw Exception('No se encontraron puntos de navegación válidos');
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error al cargar el EPUB: ${e.toString()}';
      });
    }
  }

  String? _findTocContent() {
    // Buscar archivos NCX
    final ncxFiles = epubContent.keys.where((key) => key.endsWith('.ncx'));
    for (final file in ncxFiles) {
      if (epubContent[file]?.contains('<navMap') ?? false) {
        return epubContent[file];
      }
    }

    // Buscar archivos XHTML con TOC
    final xhtmlFiles = epubContent.keys.where((key) => key.endsWith('.xhtml'));
    for (final file in xhtmlFiles) {
      final content = epubContent[file] ?? '';
      if (content.contains('epub:type="toc"')) {
        return content;
      }
    }

    return null;
  }

  void _goToNextPage() {
    if (currentNavIndex < navPoints.length - 1) {
      setState(() => currentNavIndex++);
    }
  }

  void _goToPrevPage() {
    if (currentNavIndex > 0) {
      setState(() => currentNavIndex--);
    }
  }

  void _goToPage(int index) {
    if (index >= 0 && index < navPoints.length) {
      setState(() => currentNavIndex = index);
    }
  }

  Widget _buildCurrentPage() {
    // Estados de carga y error
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (errorMessage != null) return Center(child: Text(errorMessage!));

    final currentNav = navPoints[currentNavIndex];
    final htmlContent = _getHtmlContent(currentNav.contentSrc);

    // Manejo de contenido faltante
    if (htmlContent == null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Contenido no encontrado: ${currentNav.contentSrc}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadEpubContent,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: HtmlWidget(
        htmlContent,
        onTapUrl: (String url) {
          loadEpubPage(url);
          return true;
        },
        customStylesBuilder: (element) {
          // Aplicar estilo especial para elementos con clase "subtit"
          if (element.classes.contains('subtit')) {
            return {
              'font-size': '20px', // Tamaño más grande
              'font-weight': 'bold', // Texto en negrita
              'display': 'block', // Asegurar que ocupe su propia línea
              'margin': '16px 0', // Margen superior e inferior
            };
          }
          if (element.classes.contains('subtit')) {
            return {
              'font-size': '20px', // Tamaño más grande
              'font-weight': 'bold', // Texto en negrita
              'display': 'block', // Asegurar que ocupe su propia línea
              'margin': '16px 0', // Margen superior e inferior
            };
          }
          return null;
        },
        textStyle: const TextStyle(fontSize: 18, height: 1.6),
        customWidgetBuilder: (element) {
          if (element.localName == 'img') {
            return _buildImageWidget(element.attributes['src']);
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImageWidget(String? src) {
    if (src == null) return _buildImageError();

    final imagePath = _resolveImagePath(src);
    final imageData = epubContent[imagePath];

    if (imageData is Uint8List) {
      return Image.memory(
        imageData,
        scale: 0.5,
        fit: BoxFit.scaleDown,
        errorBuilder: (_, __, ___) => _buildImageError(),
        frameBuilder: (_, child, frame, __) {
          if (frame == null) {
            return Center(child: CircularProgressIndicator());
          }
          return child;
        },
      );
    }

    return _buildImageError();
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16),
      child: const Icon(Icons.broken_image, size: 48),
    );
  }

  String? _getHtmlContent(String contentPath) {
    final pathsToTry = [
      contentPath,
      if (!contentPath.startsWith('OEBPS/')) 'OEBPS/$contentPath',
      if (contentPath.startsWith('../'))
        'OEBPS/${contentPath.replaceFirst('../', '')}',
    ];

    for (final path in pathsToTry) {
      final content = epubContent[path];
      if (content != null) return content is String ? content : null;
    }
    return null;
  }

  String _resolveImagePath(String src) {
    if (src.startsWith('OEBPS/')) return src;
    if (src.startsWith('Images/')) return 'OEBPS/$src';
    if (src.startsWith('../')) return 'OEBPS/${src.substring(3)}';
    return 'OEBPS/Images/$src';
  }

  Widget _buildChapterList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: navPoints.length,
      itemBuilder: (context, index) {
        final navPoint = navPoints[index];
        return ListTile(
          title: Text(navPoint.label),
          selected: index == currentNavIndex,
          onTap: () => _goToPage(index),
        );
      },
    );
  }

  void loadEpubPage(String url) {
    //print("Intentando cargar la página: $url");

    // 1. Eliminar el fragmento (#nt1) de la URL
    final Uri uri = Uri.parse(url);
    final String path = uri.path.replaceFirst(
      '../',
      'OEBPS/',
    ); // Reemplazar el ../ por OEBPS/
    final String fragment =
        uri.fragment; // Obtener el fragmento (por ejemplo, 'nt1')

    // 2. Buscar el contenido de la URL ajustada en epubContent
    if (epubContent.containsKey(path)) {
      final content = epubContent[path];
      if (content != null) {
        //print("Página encontrada: $path");
        _parseAndShowFragment(
          content,
          fragment,
          context,
        ); // Mostrar el fragmento específico
      } else {
        print("Contenido vacío en: $path");
      }
    } else {
      print("No se encontró contenido para la página: $path");
    }
  }

  void _parseAndShowFragment(
    String content,
    String fragmentId,
    BuildContext context,
  ) {
    try {
      // 1. Parsear el documento HTML
      final document = parse(content);

      // 2. Buscar el fragmento por ID
      final fragmentElement = document.getElementById(fragmentId);

      if (fragmentElement != null) {
        // 3. Mostrar el fragmento usando flutter_widget_from_html
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                content: SizedBox(
                  width:
                      MediaQuery.of(context).size.width *
                      0.3, // Ajusta el ancho del diálogo
                  child: SingleChildScrollView(
                    child: HtmlWidget(
                      fragmentElement.outerHtml,
                      textStyle: TextStyle(fontSize: 16),
                      customWidgetBuilder: (element) {
                        // Manejo personalizado para imágenes u otros elementos
                        if (element.localName == 'img') {
                          final src = element.attributes['src'];
                          if (src != null) {
                            // Implementa tu lógica para mostrar imágenes
                            return Image.network(src);
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cerrar'),
                  ),
                ],
              ),
        );
      } else {
        CustomSnackBar.show(
          context,
          'Fragmento $fragmentId no encontrado',
          Colors.red,
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      CustomSnackBar.show(
        context,
        'Error al parsear el fragmento: ${e.toString()}',
        Colors.red,
        duration: Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            if (isFullScreen) disableFullScreenFalse();
            _saveProgress();
            //Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Center(child: Text(widget.bookTitle)),
        actions: [
          Tooltip(
            message: "Pantalla completa",
            child: IconButton(
              onPressed: () => _toggleFullScreen(),
              icon: Icon(Icons.open_in_full),
            ),
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildChapterList(),
              );
            },
          ),
        ],
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _goToPrevPage,
              color: currentNavIndex > 0 ? null : Colors.grey,
            ),
            Text('${currentNavIndex + 1}/${navPoints.length}'),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: _goToNextPage,
              color:
                  currentNavIndex < navPoints.length - 1 ? null : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
