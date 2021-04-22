import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'blocs/account.dart';
import 'blocs/master.dart';
import 'blocs/pending_review.dart';
import 'blocs/restaurant.dart';
import 'blocs/review.dart';
import 'blocs/users.dart';
import 'models/account.dart';
import 'router.dart';
import 'routes/login/login.dart';
import 'services/sign_in.dart';
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

  late MasterBloc _bloc;

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

  _onLogout() async {
    final service = SignUpService(_self);
    await service.signOut();
    setState(() => _loggedIn = false);
  }

  _buildApp() {
    return BlocsContainer(
      blocs: _bloc,
      child: MainRouter(
        theme: theme,
        bloc: _self,
        config: widget.config,
        onLogout: _onLogout,
      ),
    );
  }

  _initBlocs() {
    final rBloc = RestaurantBloc(_self);
    rBloc.init();
    final reBloc = ReviewBloc(_self, rBloc);
    final uBloc = UserBloc(_self, rBloc);
    if (_self.account.role == UserRole.ADMIN) {
      uBloc.init();
    }
    final pBloc = PendingReviewBloc(_self, rBloc);
    if (_self.account.role == UserRole.OWNER) {
      pBloc.init();
    }
    _bloc = MasterBloc(
      aBloc: _self,
      rBloc: rBloc,
      reBloc: reBloc,
      uBloc: uBloc,
      pBloc: pBloc,
    );
  }
}
