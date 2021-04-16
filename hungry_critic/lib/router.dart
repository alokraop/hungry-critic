import 'package:flutter/material.dart';
import 'package:hungry_critic/blocs/account.dart';

import 'routes/home.dart';
import 'shared/config.dart';

class MainRouter extends StatefulWidget {
  MainRouter({
    required this.theme,
    required this.bloc,
    required this.config,
    required this.onLogout,
  });

  final ThemeData theme;

  final AccountBloc bloc;

  final AppConfig config;

  final Function() onLogout;

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
            builder: (c) => HomeScreen(bloc: widget.bloc, onLogout: widget.onLogout),
          ),
    };
    return routes[s.name]?.call();
  }
}
