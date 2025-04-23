import 'package:flutter/material.dart';

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
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.color.withOpacity(0.1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(widget.icon, size: 40, color: widget.color),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                    SizedBox(height: 10),
                    // FutureBuilder para obtener el conteo
                    FutureBuilder<int>(
                      future: _count,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Text(
                            '${snapshot.data}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: widget.color,
                            ),
                          );
                        } else {
                          return Text('No data available');
                        }
                      },
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
