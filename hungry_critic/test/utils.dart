import 'package:flutter/material.dart';

Widget wrapBareWidget(Widget widget) {
  return wrapPage(Scaffold(body: widget));
}

Widget wrapPage(Widget page) {
  return MaterialApp(
    home: page,
    onGenerateRoute: (s) => MaterialPageRoute(
      builder: (c) => Container(),
    ),
  );
}
