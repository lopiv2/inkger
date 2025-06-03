import 'package:flutter/material.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';

class CounterWidget extends StatefulWidget {
  final String title; // Título del widget
  final Future<int> Function() fetchCount; // Función que obtiene el conteo
  final Color color; // Color del widget
  final IconData icon;

  const CounterWidget({
    Key? key,
    required this.title,
    required this.fetchCount,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late Future<int> _count;

  @override
  void initState() {
    super.initState();
    // Llamamos a la función fetchCount cuando el widget se inicia
    _count = widget.fetchCount();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: isSmallScreen ? screenWidth * 0.8 : screenWidth * 0.2, // Mantener layout en resoluciones grandes
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.color.withOpacity(0.1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: isSmallScreen ? 30 : 40, // Ajustar tamaño del icono
                color: widget.color,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16, // Ajustar tamaño del texto
                          fontWeight: FontWeight.bold,
                          color: widget.color,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 5 : 10),
                    Center(
                      child: FutureBuilder<int>(
                        future: _count,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CustomLoader(size: isSmallScreen ? 40.0 : 60.0, color: Colors.blue);
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 24 : 32, // Ajustar tamaño del conteo
                                fontWeight: FontWeight.bold,
                                color: widget.color,
                              ),
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return Text('No data available');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
