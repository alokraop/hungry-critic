import 'package:flutter/material.dart';

import 'blocs/account.dart';
import 'blocs/review.dart';
import 'models/restaurant.dart';
import 'routes/uninitialized.dart';
import 'routes/home.dart';
import 'routes/restaurants/restaurant_details.dart';
import 'shared/config.dart';
import 'shared/context.dart';
import 'shared/route_transitions.dart';

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
    final bloc = BlocsContainer.of(context).reBloc;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blend',
      theme: widget.theme,
      initialRoute: '/',
      navigatorObservers: [ThreadObserver(bloc: bloc)],
      onGenerateRoute: appRoutes,
    );
  }

  Route<dynamic>? appRoutes(RouteSettings s) {
    final routes = {
      '/': () => MaterialPageRoute(
            settings: s,
            builder: (c) => widget.bloc.isBlocked
                ? BlockedScreen(onLogout: widget.onLogout)
                : HomeScreen(bloc: widget.bloc, onLogout: widget.onLogout),
          ),
      '/restaurant': () => fadeIn(
            s,
            (c) => RestaurantDetails(restaurant: s.arguments as Restaurant),
          ),
    };
    return routes[s.name]?.call();
  }
}

class ThreadObserver extends NavigatorObserver {
  ThreadObserver({required this.bloc});

  final ReviewBloc bloc;

  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _push(route);
  }

  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _pop(route);
  }

  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _pop(route);
  }

  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _pop(oldRoute);
    _push(newRoute);
  }

  _push(Route? route) {
    final settings = route?.settings;
    if (settings != null && settings.name == '/restaurant') {
      bloc.push(settings.arguments as Restaurant);
    }
  }

  _pop(Route? route) {
    final settings = route?.settings;
    if (settings != null && settings.name == '/restaurant') {
      bloc.pop();
    }
  }
}
