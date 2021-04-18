import 'dart:ui';

import 'package:hungry_critic/shared/colors.dart';

Color findColor(double rating) {
  if (rating == 0.0) return greySwatch[300];
  if (rating <= 0.5) return Color(0xffd2222d);
  if (rating <= 1.0) return Color(0xffda3c25);
  if (rating <= 1.5) return Color(0xffe1561e);
  if (rating <= 2.0) return Color(0xffe87117);
  if (rating <= 2.5) return Color(0xfff4980b);
  if (rating <= 3.0) return Color(0xffffbf00);
  if (rating <= 3.5) return Color(0xff768812);
  if (rating <= 4.0) return Color(0xff238823);
  if (rating <= 4.5) return Color(0xff0c780c);
  return Color(0xff007000);
}
