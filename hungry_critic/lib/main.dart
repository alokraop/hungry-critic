import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'blocs/account.dart';
import 'router.dart';
import 'routes/login/login.dart';
import 'shared/aspects.dart';
import 'shared/config.dart';
import 'shared/context.dart';

final theme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'NotoSans',
  primaryColor: Color(0xffcb202d),
  textTheme: TextTheme(
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
      fontSize: 13,
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
    await Aspects.instance.recordLogin(_self.account.method.toString());
    setState(() => _loggedIn = true);
  }

  _buildApp() {
    return BlocsContainer(
      aBloc: _self,
      child: MainRouter(
        theme: theme,
        config: widget.config,
        onLogOut: _onLogout,
      ),
    );
  }

  _onLogout() => setState(() => _loggedIn = false);
}
