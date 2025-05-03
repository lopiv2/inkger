import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PageFlipComicViewer extends StatefulWidget {
  final List<Uint8List> pages;

  const PageFlipComicViewer({required this.pages, Key? key}) : super(key: key);

  @override
  _PageFlipComicViewerState createState() => _PageFlipComicViewerState();
}

class _PageFlipComicViewerState extends State<PageFlipComicViewer>
    with TickerProviderStateMixin {
  int currentIndex = 0;
  late AnimationController _controller;
  //late Animation<Offset> _dragAnimation;
  late Animation<double> _scaleAnimation;
  Offset dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      dragOffset = details.localPosition;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (dragOffset.dx < -100 && currentIndex < widget.pages.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else if (dragOffset.dx > 100 && currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }

    setState(() {
      dragOffset = Offset.zero;
    });

    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    Uint8List currentPage = widget.pages[currentIndex];
    Uint8List? nextPage = currentIndex < widget.pages.length - 1
        ? widget.pages[currentIndex + 1]
        : null;

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (nextPage != null)
            Image.memory(nextPage, fit: BoxFit.cover),
          FutureBuilder<ui.Image>(
            future: _decodeImage(currentPage),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              return CustomPaint(
                painter: PageFlipPainter(
                  image: snapshot.data!,
                  dragOffset: dragOffset,
                  scale: _scaleAnimation.value,
                ),
                size: Size.infinite,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<ui.Image> _decodeImage(Uint8List data) async {
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

class PageFlipPainter extends CustomPainter {
  final ui.Image image;
  final Offset dragOffset;
  final double scale;

  PageFlipPainter({
    required this.image,
    required this.dragOffset,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Apply scaling for smooth transitions
    final rect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final scaledSize = imageSize * scale;

    canvas.drawImageRect(
      image,
      rect,
      Rect.fromLTWH(0, 0, scaledSize.width, scaledSize.height),
      paint,
    );

    if (dragOffset.dx != 0) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.4);
      canvas.drawRect(Rect.fromLTWH(dragOffset.dx, 0, 30, size.height), shadowPaint);
    }
  }

  @override
  bool shouldRepaint(PageFlipPainter oldDelegate) {
    return dragOffset != oldDelegate.dragOffset || scale != oldDelegate.scale;
  }
}
