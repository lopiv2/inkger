import 'package:flutter/material.dart';
import 'dart:typed_data';

class TransformControllerWidget extends StatefulWidget {
  @override
  _TransformControllerWidgetState createState() =>
      _TransformControllerWidgetState();
}

class _TransformControllerWidgetState extends State<TransformControllerWidget> {
  double rotationY = 0.0; // Rotación en Y
  double skewTopLeft = 0.0; // Sesgo superior izquierda
  double skewBottomLeft = 0.0; // Sesgo inferior izquierda
  double translateX = 0.0; // Traslación en X
  double translateY = 0.0; // Traslación en Y

  // Imagen de prueba (sustituye con tu propia imagen)
  final Uint8List dummyImage = Uint8List.fromList(
    List.generate(10000, (index) => index % 256),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Control de Transformaciones")),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: Transform(
                transform:
                    Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspectiva
                      ..rotateY(rotationY) // Rotación Y
                      ..setEntry(1, 0, skewTopLeft) // Sesgo superior izquierda
                      ..setEntry(
                        0,
                        0,
                        1.0 - skewBottomLeft,
                      ) // Sesgo inferior izquierda
                      ..translate(translateX, translateY), // Traslación X e Y
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/cover.jpg',
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.15,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  buildSlider(
                    "Rotación Y",
                    rotationY,
                    -1.0,
                    1.0,
                    (value) => setState(() => rotationY = value),
                  ),
                  buildSlider(
                    "Sesgo Sup. Izq.",
                    skewTopLeft,
                    -0.5,
                    0.5,
                    (value) => setState(() => skewTopLeft = value),
                  ),
                  buildSlider(
                    "Sesgo Inf. Izq.",
                    skewBottomLeft,
                    -0.5,
                    0.5,
                    (value) => setState(() => skewBottomLeft = value),
                  ),
                  buildSlider(
                    "Traslación X",
                    translateX,
                    -50.0,
                    50.0,
                    (value) => setState(() => translateX = value),
                  ),
                  buildSlider(
                    "Traslación Y",
                    translateY,
                    -50.0,
                    50.0,
                    (value) => setState(() => translateY = value),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toStringAsFixed(2)}"),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}
