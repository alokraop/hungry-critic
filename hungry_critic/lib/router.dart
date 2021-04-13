import 'package:flutter/material.dart';

import 'routes/home/home.dart';
import 'shared/config.dart';

class MainRouter extends StatefulWidget {
  MainRouter({
    required this.theme,
    required this.config,
    required this.onLogOut,
  });

  final ThemeData theme;

  final AppConfig config;

  final Function() onLogOut;

  @override
  _MainRouterState createState() => _MainRouterState();
}

class _MainRouterState extends State<MainRouter> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blend',
      theme: widget.theme,
      initialRoute: '/',
      onGenerateRoute: appRoutes,
    );
  }

  Route<dynamic>? appRoutes(RouteSettings s) {
    final routes = {
      '/': () => MaterialPageRoute(
            settings: s,
            builder: (c) => HomeScreen(onDelete: widget.onLogOut),
          ),
    };
    return routes[s.name]?.call();
  }
}
