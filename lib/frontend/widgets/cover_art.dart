import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/common_services.dart';

Widget buildCoverImage(String? coverPath, {bool calculateColor = false}) {
    return FutureBuilder<Uint8List?>(
      future: coverPath != null ? CommonServices.getCover(coverPath) : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Icon(Icons.broken_image, size: 50));
        }

        // Cálculo del color solo cuando hay datos y es necesario
        /*if (calculateColor && !_colorCalculated && snapshot.hasData) {
          _calculateDominantColor(snapshot.data!);
          _colorCalculated = true;
        }*/

        return FittedBox(
          fit: BoxFit.contain,
          child: Image.memory(snapshot.data!, fit: BoxFit.contain),
        );
      },
    );
  }