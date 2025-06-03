import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';

Widget buildCoverImageGoogle(String? coverPath, {bool calculateColor = false}) {
  return FutureBuilder<Uint8List?>(
    future: coverPath != null && coverPath.isNotEmpty
        ? CommonServices.getCover(coverPath)
        : Future.value(null),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CustomLoader(size: 60.0, color: Colors.blue));
      }
      if (snapshot.hasError || !snapshot.hasData) {
        return FittedBox(
          fit: BoxFit.contain,
          child: Image.asset('assets/images/noImage.png', fit: BoxFit.contain),
        );
      }

      return FittedBox(
        fit: BoxFit.contain,
        child: Image.memory(snapshot.data!, fit: BoxFit.contain),
      );
    },
  );
}

Widget buildCoverImage(
  String? coverPath, {
  double? width,
  double? height,
  bool calculateColor = false,
}) {
  return FutureBuilder<Uint8List?>(
    future: coverPath != null && coverPath.isNotEmpty
        ? CommonServices.getCover(coverPath)
        : Future.value(null),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CustomLoader(size: 60.0, color: Colors.blue));
      }
      if (snapshot.hasError || !snapshot.hasData) {
        return Image.asset(
          'assets/images/noImage.png',
          fit: BoxFit.contain,
          width: width,
          height: height,
        );
      }

      return Image.memory(
        snapshot.data!,
        fit: BoxFit.cover,
        width: width,
        height: height,
      );
    },
  );
}

Widget buildMultiCover(List<String> itemCovers) {
  if (itemCovers.length == 1) {
    // Caso de una sola imagen
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: buildCoverImage(itemCovers[0]),
    );
  }

  if (itemCovers.length == 2) {
    // Caso de dos imágenes
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Dos columnas
        crossAxisSpacing: 0, // Sin espacio entre columnas
        mainAxisSpacing: 0, // Sin espacio entre filas
      ),
      itemCount: 4, // Dos filas por columna
      itemBuilder: (context, index) {
        final imageIndex = index % 2; // Alternar entre las dos imágenes
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: buildCoverImage(itemCovers[imageIndex]),
        );
      },
      physics: const NeverScrollableScrollPhysics(), // Deshabilitar scroll
      shrinkWrap: true, // Ajustar tamaño al contenido
    );
  }

  if (itemCovers.length == 3) {
    // Caso de tres imágenes
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Dos columnas
        crossAxisSpacing: 0, // Sin espacio entre columnas
        mainAxisSpacing: 0, // Sin espacio entre filas
      ),
      itemCount: 4, // Cuatro posiciones en la cuadrícula
      itemBuilder: (context, index) {
        final imageIndex = index % 3; // Alternar entre las tres imágenes
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: buildCoverImage(itemCovers[imageIndex]),
        );
      },
      physics: const NeverScrollableScrollPhysics(), // Deshabilitar scroll
      shrinkWrap: true, // Ajustar tamaño al contenido
    );
  }

  // Caso de más de tres imágenes
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, // Máximo 2 columnas
      crossAxisSpacing: 0, // Sin espacio entre columnas
      mainAxisSpacing: 0, // Sin espacio entre filas
    ),
    itemCount: itemCovers.length > 4
        ? 4
        : itemCovers.length, // Máximo 4 imágenes
    itemBuilder: (context, index) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: buildCoverImage(itemCovers[index]),
      );
    },
    physics: const NeverScrollableScrollPhysics(), // Deshabilitar scroll
    shrinkWrap: true, // Ajustar tamaño al contenido
  );
}
