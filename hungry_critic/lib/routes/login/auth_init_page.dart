import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:hungry_critic/models/account.dart';
import 'package:hungry_critic/shared/aspects.dart';
import 'package:hungry_critic/shared/colors.dart';

import '../../services/sign_in.dart';

final _lMap = <SignInMethod, String>{
  SignInMethod.GOOGLE: 'google',
  SignInMethod.TWITTER: 'twitter',
};

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class AuthInitPage extends StatefulWidget {
  final SignUpService service;
  final Function onAuto;
  final Function onManual;

  AuthInitPage({
    Key? key,
    required this.service,
    required this.onAuto,
    required this.onManual,
  }) : super(key: key);

  @override
  _AuthInitPageState createState() => _AuthInitPageState();
}

class _AuthInitPageState extends State<AuthInitPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _loading = false;
  bool unsubmitted = true;

  SignInMethod? _method;
  bool _invalidInput = false;
  bool _connectionFailure = false;

  bool _hasFocus = false;
  late StreamSubscription<bool> _sub;

  late ThemeData _theme;

  @override
  void initState() {
    super.initState();
    final kVis = KeyboardVisibilityController();
    _sub = kVis.onChange.listen((on) => setState(() => _hasFocus = on));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runSpacing: 7.5,
            children: [
              _socialButton(SignInMethod.GOOGLE, greySwatch[50], greySwatch[500]),
              _socialButton(SignInMethod.TWITTER, Color(0xff1da1f2), greySwatch[50]),
            ],
          ),
        ),
      ],
    );
  }

  _socialButton(SignInMethod method, Color bColor, Color fColor) {
    final imageName = _lMap[method]?.toLowerCase() ?? '';
    final label = imageName.capitalize();
    return GestureDetector(
      onTap: () => _authWithSocial(method),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: bColor,
          borderRadius: BorderRadius.circular(7.5),
          boxShadow: [
            BoxShadow(
              color: greySwatch[800].withOpacity(0.4),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logos/${imageName}_signin.png',
                width: 25,
              ),
            ),
            SizedBox(width: 5),
            Text(
              '$label',
              style: _theme.textTheme.bodyText1?.copyWith(
                fontFamily: 'Roboto',
                color: fColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _authWithSocial(SignInMethod method) async {
    _onError(e) => _showError(e, method);
    if (_loading) return;
    FocusScope.of(context).requestFocus(new FocusNode());
    _loading = true;
    setState(() {});
    widget.service.authWithSocial(method, widget.onAuto).catchError(_onError);
  }

  _showError(Object exception, SignInMethod method) {
    Aspects.instance.log('AuthInitPage -> error');
    _loading = false;
    _method = method;
    switch (method) {
      case SignInMethod.GOOGLE:
        if (exception is PlatformException && exception.code == 'SIGN_IN_CANCELED') {
          Aspects.instance.log('Login -> $method -> Canceled');
        } else {
          Aspects.instance.recordError(exception);
          _connectionFailure = true;
        }
        break;
      default:
    }
    setState(() {});
  }

  Widget _showSocialError() {
    final social = [SignInMethod.TWITTER, SignInMethod.GOOGLE].contains(_method);
    if (social) {
      if (_invalidInput) return _makeError('Something went wrong! Try again.');
      if (_connectionFailure) return _makeError('Check your network and try again!');
    }
    return Container();
  }

  _makeError(String text) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        text,
        style: _theme.textTheme.caption?.copyWith(color: _theme.errorColor),
      ),
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
