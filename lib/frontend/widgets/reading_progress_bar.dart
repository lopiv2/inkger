import 'package:flutter/material.dart';

class ReadingProgressBarIndicator extends StatelessWidget {
  final double value;

  const ReadingProgressBarIndicator({Key? key, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        LinearProgressIndicator(
          value: value / 100,
          minHeight: 12,
          backgroundColor: Colors.green[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
        value>=50 ?
        Text(
          '${value.toStringAsFixed(1)}%', // Mostrar el progreso con un decimal
          style: TextStyle(
            color: Theme.of(context).secondaryHeaderColor, // Cambiar el color según el diseño
            fontWeight: FontWeight.bold,
          ),
        ) : Text(
          '${value.toStringAsFixed(1)}%', // Mostrar el progreso con un decimal
          style: TextStyle(
            color: Theme.of(context).primaryColor, // Cambiar el color según el diseño
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}