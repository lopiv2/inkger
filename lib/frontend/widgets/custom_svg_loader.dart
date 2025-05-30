import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final bool useSpinKit;
  final SpinKitWaveType spinKitType; // Para configurar el tipo de SpinKit si se usa

  const CustomLoader({
    super.key,
    this.size = 40.0,
    this.color,
    this.useSpinKit = true,
    this.spinKitType = SpinKitWaveType.start,
  });

  @override
  Widget build(BuildContext context) {
    if (useSpinKit) {
      return SpinKitPouringHourGlassRefined(
        color: color ?? Theme.of(context).colorScheme.primary,
        size: size,
        //type: spinKitType,
      );
      // Puedes cambiar SpinKitWave por otros widgets de SpinKit aquí
    } else {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: color != null
              ? AlwaysStoppedAnimation<Color>(color!)
              : null, // Usa el color del tema por defecto si no se especifica
        ),
      );
    }
  }
}