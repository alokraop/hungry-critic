import 'package:flutter/material.dart';

import '../../blocs/account.dart';

class LoginScreens extends StatefulWidget {
  const LoginScreens({
    Key? key,
    required this.bloc,
    required this.onLogin,
  }) : super(key: key);

  final AccountBloc bloc;

  final Function() onLogin;

  @override
  _LoginScreensState createState() => _LoginScreensState();
}

class _LoginScreensState extends State<LoginScreens> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
