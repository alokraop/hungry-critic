import 'dart:io';

import 'package:flutter/material.dart';

Route<T> slideUp<T>(Widget Function(BuildContext) builder, [RouteSettings? settings]) {
  return Platform.isIOS
      ? MaterialPageRoute<T>(settings: settings, builder: builder)
      : SlideUpRoute<T>(settings: settings, builder: builder);
}

Route fadeIn(RouteSettings settings, Widget Function(BuildContext) builder) {
  return Platform.isIOS
      ? MaterialPageRoute(settings: settings, builder: builder)
      : FadeRoute(settings: settings, builder: builder);
}

class FadeRoute extends PageRouteBuilder {
  final WidgetBuilder builder;

  @protected
  bool get hasScopedWillPopCallback {
    return false;
  }

  FadeRoute({
    RouteSettings? settings,
    required this.builder,
  }) : super(
          settings: settings,
          pageBuilder: (c, a, s) {
            return Semantics(
              scopesRoute: true,
              explicitChildNodes: true,
              child: builder(c),
            );
          },
          transitionDuration: Duration(milliseconds: 200),
          transitionsBuilder: (
            context,
            animation,
            ssecondary,
            child,
          ) =>
              FadeTransition(
            opacity: CurvedAnimation(
              curve: Curves.easeIn,
              parent: animation,
            ),
            child: child,
          ),
        );
}

class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  SlideUpRoute({
    RouteSettings? settings,
    required this.builder,
  }) : super(
          settings: settings,
          pageBuilder: (c, a, s) => builder(c),
          transitionDuration: Duration(milliseconds: 200),
          transitionsBuilder: (
            context,
            animation,
            ssecondary,
            child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInBack,
                reverseCurve: Curves.easeInOutSine,
              ),
            ),
            child: child,
          ),
        );
}

class SlideRightRoute extends PageRouteBuilder {
  final WidgetBuilder builder;

  SlideRightRoute({
    RouteSettings? settings,
    required this.builder,
  }) : super(
          settings: settings,
          pageBuilder: (c, a, s) => builder(c),
          transitionDuration: Duration(milliseconds: 300),
          transitionsBuilder: (
            context,
            animation,
            ssecondary,
            child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInBack,
                reverseCurve: Curves.easeInOutSine,
              ),
            ),
            child: child,
          ),
        );
}
