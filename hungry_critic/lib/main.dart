import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'blocs/account.dart';
import 'blocs/restaurant.dart';
import 'blocs/review.dart';
import 'blocs/users.dart';
import 'models/account.dart';
import 'router.dart';
import 'routes/login/login.dart';
import 'shared/aspects.dart';
import 'shared/colors.dart';
import 'shared/config.dart';
import 'shared/context.dart';

final theme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'NotoSans',
  primaryColor: swatch,
  primarySwatch: swatch.material,
  textTheme: TextTheme(
    headline4: TextStyle(
      debugLabel: 'stock subTitle',
      fontSize: 26,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
    ),
    headline5: TextStyle(
      debugLabel: 'stock subTitle',
      fontSize: 24,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
    ),
    headline6: TextStyle(
      debugLabel: 'stock headline6',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
    ),
    subtitle1: TextStyle(
      debugLabel: 'stock subTitle',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
    ),
    bodyText1: TextStyle(
      debugLabel: 'stock body',
      fontSize: 14.75,
      decoration: TextDecoration.none,
    ),
    bodyText2: TextStyle(
      debugLabel: 'stock body',
      fontSize: 13.75,
      decoration: TextDecoration.none,
    ),
    caption: TextStyle(
      debugLabel: 'stock badge',
      fontSize: 12.5,
      decoration: TextDecoration.none,
    ),
  ),
);

void startApp(AppConfig config) => runApp(HungryCritic(config: config));

class HungryCritic extends StatefulWidget {
  HungryCritic({Key? key, required this.config}) : super(key: key);

  final AppConfig config;

  @override
  _HungryCriticState createState() => _HungryCriticState();
}

class _HungryCriticState extends State<HungryCritic> {
  bool _initialized = false;
  bool _loggedIn = true;

  late AccountBloc _self;

  late RestaurantBloc _rBloc;

  late ReviewBloc _reBloc;

  late UserBloc _uBloc;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((_) {
      _self = AccountBloc(widget.config);
      _self.init().then(_onProfile);
    });
  }

  void _onProfile(bool exists) {
    _initialized = true;
    _loggedIn = exists;
    if (exists) _initBlocs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? _loggedIn
            ? _buildApp()
            : _buildLogin()
        : Container();
  }

  _buildLogin() {
    final screen = LoginScreens(bloc: _self, onLogin: _onLogin);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blend',
      theme: theme,
      home: screen,
    );
  }

  _onLogin() async {
    await Aspects.instance.recordLogin(_self.account.settings.method.toString());
    _initBlocs();
    setState(() => _loggedIn = true);
  }

  _onLogout() {
    setState(() => _loggedIn = false);
  }

  _buildApp() {
    return BlocsContainer(
      aBloc: _self,
      rBloc: _rBloc,
      uBloc: _uBloc,
      reBloc: _reBloc,
      child: MainRouter(
        theme: theme,
        bloc: _self,
        config: widget.config,
        onLogout: _onLogout,
      ),
    );
  }

  _initBlocs() {
    _rBloc = RestaurantBloc(_self);
    _rBloc.init();
    _reBloc = ReviewBloc(_self, _rBloc);
    _uBloc = UserBloc(_self);
    if (_self.account.role == UserRole.ADMIN) {
      _uBloc.init();
    }
  }
}
