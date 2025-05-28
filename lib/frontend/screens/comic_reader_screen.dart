import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/services/comic_services.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:archive/archive.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomReaderComic extends StatefulWidget {
  final Uint8List cbzBytes;
  final String comicTitle;
  final int initialProgress;
  final int comicId;
  final String? previousScreen;

  const CustomReaderComic({
    Key? key,
    required this.cbzBytes,
    required this.comicTitle,
    required this.initialProgress,
    required this.comicId,
    this.previousScreen,
  }) : super(key: key);

  @override
  _CustomReaderComicState createState() => _CustomReaderComicState();
}

class _CustomReaderComicState extends State<CustomReaderComic>
    with FullScreenListener {
  late List<String> _imagePaths = [];
  late List<Uint8List> _imageData = [];
  int _currentPageIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFullScreen = false;
  double zoomLevel = 1.0;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    FullScreen.addListener(this);
    _loadCbzContent().then((_) {
      // Esperar a que se cargue el contenido antes de calcular la página inicial
      if (mounted) {
        setState(() {
          _currentPageIndex =
              ((widget.initialProgress / 100) * (_imagePaths.length - 1))
                  .round();
          _pageController = PageController(initialPage: _currentPageIndex);
        });
      }
    });
  }

  @override
  void dispose() {
    FullScreen.removeListener(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void onFullScreenChanged(bool enabled, SystemUiMode? systemUiMode) {
    setState(() {
      _isFullScreen = enabled;
    });
  }

  void _disableFullScreen() async {
    Provider.of<PreferencesProvider>(
      context,
      listen: false,
    ).toggleFullScreenMode(false);
    FullScreen.setFullScreen(false);
  }

  void _toggleFullScreen() async {
    if (!_isFullScreen) {
      Provider.of<PreferencesProvider>(
        context,
        listen: false,
      ).toggleFullScreenMode(true);
      FullScreen.setFullScreen(true);
    } else {
      _disableFullScreen();
    }
  }

  Future<void> _saveProgress() async {
    if (_imagePaths.isEmpty) return;

    int progress = ((_currentPageIndex / (_imagePaths.length - 1)) * 100)
        .round();
    await ComicServices.saveReadingProgress(widget.comicId, progress, context);
    final provider = Provider.of<ComicsProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    // Campos requeridos
    final id = prefs.getInt('id');
    await provider.loadcomics(id ?? 0);
    // Notificar el refresco
    if (widget.previousScreen!.contains('reading-lists')) {
      context.go('/reading-lists');
    } else {
      context.pop();
    }
  }

  Future<void> _loadCbzContent() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final archive = ZipDecoder().decodeBytes(widget.cbzBytes);

      // Obtener y ordenar las imágenes
      _imagePaths =
          archive.files
              .where((file) => file.isFile && _isImageFile(file.name))
              .map((file) => file.name)
              .toList()
            ..sort((a, b) => a.compareTo(b));

      // Precargar las imágenes cercanas al punto de progreso
      final initialProgressIndex =
          ((widget.initialProgress / 100) * (_imagePaths.length - 1)).round();
      final startIndex = (initialProgressIndex - 5).clamp(
        0,
        _imagePaths.length - 1,
      );
      final endIndex = (initialProgressIndex + 5).clamp(
        0,
        _imagePaths.length - 1,
      );

      _imageData = List.filled(_imagePaths.length, Uint8List(0));

      for (int i = startIndex; i <= endIndex; i++) {
        final file = archive.files.firstWhere((f) => f.name == _imagePaths[i]);
        _imageData[i] = await _decodeImage(file.content);
      }

      // Cargar el resto de imágenes en segundo plano
      _loadRemainingImages(archive);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar el CBZ: ${e.toString()}';
      });
    }
  }

  Future<void> _loadRemainingImages(Archive archive) async {
    for (int i = 0; i < _imagePaths.length; i++) {
      if (_imageData[i].isEmpty) {
        final file = archive.files.firstWhere((f) => f.name == _imagePaths[i]);
        final image = await _decodeImage(file.content);
        if (mounted) {
          setState(() {
            _imageData[i] = image;
          });
        }
      }
    }
  }

  bool _isImageFile(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  Future<Uint8List> _decodeImage(Uint8List bytes) async {
    try {
      // Comprimir la imagen para mejor rendimiento
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minHeight: 1920,
        minWidth: 1080,
        quality: 85,
      );
      return result;
    } catch (e) {
      return bytes; // Si falla la compresión, devolver original
    }
  }

  void _goToNextPage() {
    if (_currentPageIndex < _imagePaths.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPrevPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /*Widget _buildImageViewer() {
    if (_isLoading) {
      return Center(child: CustomLoader(size: 60.0, color: Colors.blue)());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_imageData.isEmpty) {
      return Center(child: Text('No se encontraron imágenes en el archivo'));
    }

    return GestureDetector(
      onDoubleTap: _toggleFullScreen,
      onScaleUpdate: (details) {
        setState(() {
          zoomLevel = details.scale.clamp(0.5, 3.0);
        });
      },
      child:
          _imageData.isEmpty
              ? const Center(child: CustomLoader(size: 60.0, color: Colors.blue)())
              : PageFlipComicViewer(pages: _imageData),
    );
  }*/

  void _goToPage(int index) {
    if (index >= 0 && index < _imagePaths.length) {
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildImageViewer() {
    if (_isLoading) {
      return Center(child: CustomLoader(size: 60.0, color: Colors.blue));
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_imageData.isEmpty) {
      return Center(child: Text('No se encontraron imágenes en el archivo'));
    }

    return GestureDetector(
      onDoubleTap: _toggleFullScreen,
      onScaleUpdate: (details) {
        setState(() {
          zoomLevel = details.scale.clamp(0.5, 3.0);
        });
      },
      child: PageView.builder(
        controller: _pageController,
        itemCount: _imageData.length,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs().clamp(0.0, 1.0)));
              } else {
                value = index == _currentPageIndex ? 1.0 : 0.0;
              }

              final rotation =
                  (_pageController.page ?? _currentPageIndex) - index;

              return Transform(
                alignment: rotation < 0
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(
                    rotation * 1.2,
                  ), // mayor ángulo para hoja más realista
                child: Opacity(
                  opacity: value,
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Center(
                      child: Image.memory(
                        _imageData[index],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _buildImageError(),
                        frameBuilder: (_, child, frame, __) {
                          if (frame == null) {
                            return Center(child: CustomLoader(size: 60.0, color: Colors.blue));
                          }
                          return child;
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16),
      child: const Icon(Icons.broken_image, size: 48),
    );
  }

  Widget _buildPageList() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _imagePaths.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _goToPage(index);
            Navigator.pop(context);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(_imageData[index], fit: BoxFit.cover),
              if (index == _currentPageIndex)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 3),
                  ),
                ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: EdgeInsets.all(4),
                  color: Colors.black54,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            if (_isFullScreen) _disableFullScreen();
            _saveProgress();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Center(child: Text(widget.comicTitle)),
        actions: [
          Tooltip(
            message: "Pantalla completa",
            child: IconButton(
              onPressed: _toggleFullScreen,
              icon: Icon(Icons.open_in_full),
            ),
          ),
          IconButton(
            icon: Icon(Icons.grid_view),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Column(
                    children: [
                      AppBar(
                        title: Text('Seleccionar página'),
                        actions: [
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      Expanded(child: _buildPageList()),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildImageViewer(),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _goToPrevPage,
              color: _currentPageIndex > 0 ? null : Colors.grey,
            ),
            Text('${_currentPageIndex + 1}/${_imagePaths.length}'),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: _goToNextPage,
              color: _currentPageIndex < _imagePaths.length - 1
                  ? null
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
