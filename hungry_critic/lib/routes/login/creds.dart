import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:hungry_critic/apis/signIn.dart';
import 'package:hungry_critic/models/account.dart';
import 'package:hungry_critic/shared/aspects.dart';
import 'package:hungry_critic/shared/colors.dart';
import 'package:hungry_critic/shared/custom_text_fields.dart';
import 'package:hungry_critic/shared/divider.dart';

import '../../services/sign_in.dart';

const eReg =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class AuthInitPage extends StatefulWidget {
  final SignUpService service;
  final Function(bool) onAuto;
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
  final _emailC = TextEditingController();
  bool _loading = false;
  bool unsubmitted = true;

  SignInMethod? _method;

  late ThemeData _theme;
  late Size _screen;

  var _status = AuthStatus.NONE;
  bool _create = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _screen = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTitle(),
            SizedBox(height: 20),
            _buildEmailLogin(),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: LabelDivider(
                color: greySwatch[500],
                content: Text(
                  _create ? 'or sign-up with' : 'or sign-in with',
                  style: _theme.textTheme.bodyText2?.copyWith(
                    color: _theme.primaryColor,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildSocial(),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: _buildSwap(),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: _screen.width * 0.2,
          color: _theme.primaryColor,
          colorBlendMode: BlendMode.srcIn,
        ),
        Text(
          'Hungry Critic',
          style: _theme.textTheme.headline5?.copyWith(
            color: _theme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  _buildEmailLogin() {
    return SizedBox(
      width: _screen.width * 0.85,
      child: Row(
        children: [
          Expanded(
            child: UnderlinedTextField(
              key: ValueKey('username'),
              state: _formKey,
              controller: _emailC,
              hintText: 'Email address',
              prefixIcon: Icon(
                Icons.email,
              ),
              caps: TextCapitalization.none,
              maxLength: 50,
              validator: _validateEmail,
            ),
          ),
          SizedBox(width: 10),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 50),
            child: FloatingActionButton(
              key: ValueKey('submitPhoneNumber'),
              onPressed: _authWithEmail,
              child: Icon(Icons.arrow_forward),
              backgroundColor: _theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocial() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 7.5,
            children: [
              _socialButton(
                SignInMethod.GOOGLE,
                greySwatch[50],
                greySwatch[500],
                greySwatch[800].withOpacity(0.4),
              ),
              SizedBox(width: 15),
              _socialButton(
                SignInMethod.FACEBOOK,
                Color(0xff3b5998),
                greySwatch[50],
                greySwatch[800].withOpacity(0.6),
              ),
            ],
          ),
        ),
        SizedBox(height: 7.5),
        _showSocialError(),
      ],
    );
  }

  _socialButton(
    SignInMethod method,
    Color bColor,
    Color fColor,
    Color sColor,
  ) {
    final imageName = describeEnum(method).toLowerCase();
    final label = imageName.capitalize();
    return GestureDetector(
      onTap: () => _authWithSocial(method),
      child: Container(
        width: _screen.width * 0.325,
        padding: EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
        decoration: BoxDecoration(
          color: bColor,
          borderRadius: BorderRadius.circular(7.5),
          boxShadow: [
            BoxShadow(
              color: greySwatch[800].withOpacity(0.4),
              blurRadius: 3,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logos/${imageName}_signin.png',
                height: 27.5,
              ),
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
          ],
        ),
      ),
    );
  }

  _buildSwap() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: Text(
            _create ? 'Already have an account?' : 'Don\'t have an account?',
            style: _theme.textTheme.caption,
          ),
        ),
        SizedBox(width: 5),
        TextButton(
          child: Text(
            _create ? 'SIGN IN' : 'CREATE ACCOUNT',
            style: _theme.textTheme.bodyText2?.copyWith(color: _theme.primaryColor),
          ),
          onPressed: _toggleCreate,
        )
      ],
    );
  }

  _toggleCreate() => setState(() => _create = !_create);

  _authWithEmail() {}

  _authWithSocial(SignInMethod method) async {
    _onError(e) => _showError(e, method);
    if (_loading) return;
    FocusScope.of(context).requestFocus(new FocusNode());
    _loading = true;
    setState(() {});
    final data = SignInData(_create, method);
    widget.service.authWithSocial(data, _onSuccess).catchError(_onError);
  }

  _showError(Object exception, SignInMethod method) {
    Aspects.instance.log('AuthInitPage -> error');
    _loading = false;
    _method = method;
    switch (method) {
      case SignInMethod.GOOGLE:
        if (exception is PlatformException && exception.code == 'SIGN_IN_CANCELED') {
          Aspects.instance.log('Login -> $method -> Canceled');
        }
        if (exception is LoginException) {
          Aspects.instance.log('Login -> $method -> Fail');
          switch (exception.status) {
            case 400:
              if (_create) _status = AuthStatus.DUPLICATE;
              break;
          }
        } else {
          Aspects.instance.recordError(exception);
          _status = AuthStatus.ERROR;
        }
        break;
      default:
    }
    setState(() {});
  }

  _onSuccess(AuthStatus status) {
    switch (status) {
      case AuthStatus.UNVERIFIED:
        widget.onManual();
        break;
      case AuthStatus.NEW_ACCOUNT:
        widget.onAuto(true);
        break;
      case AuthStatus.EXISTING_ACCOUNT:
        widget.onAuto(false);
        break;
      default:
    }
  }

  Widget _showSocialError() {
    final social = [SignInMethod.FACEBOOK, SignInMethod.GOOGLE].contains(_method);
    if (social) {
      switch (_status) {
        case AuthStatus.DUPLICATE:
          return _makeError('An account already exists. Try signing in!');
        case AuthStatus.ERROR:
          return _makeError('Something went wrong! Try again.');
        default:
      }
    }
    return Container();
  }

  _makeError(String text) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error, color: _theme.errorColor, size: 18),
          SizedBox(width: 5),
          Text(
            text,
            style: _theme.textTheme.caption?.copyWith(
              color: _theme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    value ??= '';
    if (!RegExp(eReg).hasMatch(value)) return 'Invalid email address';
    if (_status == AuthStatus.NO_ACCOUNT) return 'No account found';
    if (_status == AuthStatus.DUPLICATE) {
      _status = AuthStatus.NONE;
      return 'This email already has an account!';
    }
    return null;
  }
}
