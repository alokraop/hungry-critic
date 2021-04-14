import 'package:flutter/widgets.dart';

class GreySwatch extends ColorSwatch<int> {
  const GreySwatch(this.base, this.swatch) : super(base, swatch);

  final int base;

  final Map<int, Color> swatch;

  Color operator [](int index) => swatch[index] ?? Color(base);
}

final greySwatch = GreySwatch(
  0xff4a6572,
  <int, Color>{
    50: Color(0xffffffff),
    100: Color(0xffe5e5e5),
    200: Color(0xffb2b2b2),
    300: Color(0xff999999),
    400: Color(0xff7f7f7f),
    500: Color(0xff666666),
    600: Color(0xff4c4c4c),
    700: Color(0xff333333),
    800: Color(0xff191919),
    900: Color(0xff000000)
  },
);