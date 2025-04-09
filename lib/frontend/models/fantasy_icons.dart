// Place fonts/fantasy.ttf in your fonts/ directory and
// add the following to your pubspec.yaml
// flutter:
//   fonts:
//    - family: fantasy
//      fonts:
//       - asset: fonts/fantasy.ttf
import 'package:flutter/widgets.dart';

class Fantasy {
  Fantasy._();

  static const String _fontFamily = 'fantasy';

  static const IconData dwarf = IconData(0xe900, fontFamily: _fontFamily);
  static const IconData elf = IconData(0xe901, fontFamily: _fontFamily);
  static const IconData human = IconData(0xe902, fontFamily: _fontFamily);
  static const IconData hydra = IconData(0xe903, fontFamily: _fontFamily);
  static const IconData magicWand = IconData(0xe904, fontFamily: _fontFamily);
  static const IconData ocean = IconData(0xe905, fontFamily: _fontFamily);
  static const IconData village = IconData(0xe906, fontFamily: _fontFamily);
  static const IconData weapons = IconData(0xe907, fontFamily: _fontFamily);
  static const IconData werewolf = IconData(0xe908, fontFamily: _fontFamily);
}
