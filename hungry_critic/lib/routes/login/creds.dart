import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hungry_critic/shared/social_button.dart';

import '../../apis/signIn.dart';
import '../../models/account.dart';
import '../../services/sign_in.dart';
import '../../shared/aspects.dart';
import '../../shared/colors.dart';
import '../../shared/custom_text_fields.dart';
import '../../shared/divider.dart';

const eReg =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

class AuthInitPage extends StatefulWidget {
  final SignUpService service;
  final Function(bool) onAuto;
  final Function onManual;
  final Function onDrop;

  AuthInitPage({
    Key? key,
    required this.service,
    required this.onAuto,
    required this.onManual,
    required this.onDrop,
  }) : super(key: key);

  @override
  _AuthInitPageState createState() => _AuthInitPageState();
}

class _AuthInitPageState extends State<AuthInitPage> with SingleTickerProviderStateMixin {
  final _emailKey = GlobalKey<FormState>();
  final _passKey = GlobalKey<FormState>();

  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _cPassC = TextEditingController();
  bool _loading = false;
  bool unsubmitted = true;

  SignInMethod? _method;

  late ThemeData _theme;
  late Size _screen;

  var _status = AuthStatus.NONE;
  bool _create = false;

  late Animation<double> _methods;
  late AnimationController _pass;

  @override
  void initState() {
    super.initState();
    _pass = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _methods = Tween(begin: 1.0, end: 0.0).animate(_pass);
  }

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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _screen.width * 0.075),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTitle(),
              SizedBox(height: 25),
              Text(
                _create ? 'CREATE AN ACCOUNT WITH:' : 'SIGN INTO YOUR ACCOUNT WITH:',
                style: _theme.textTheme.bodyText2?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 15),
              _buildMethods(),
              _buildPasswords(),
            ],
          ),
        ),
        _buildSwap(),
      ],
    );
  }

  Widget _buildMethods() {
    return SizeTransition(
      sizeFactor: _methods,
      child: Form(
        key: _emailKey,
        child: Column(
          children: [
            _buildEmailLogin(),
            SizedBox(height: 10),
            LabelDivider(
              color: greySwatch[500],
              content: Text(
                'OR',
                style: _theme.textTheme.caption?.copyWith(
                  color: _theme.primaryColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildSocial(),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswords() {
    return SizeTransition(
      sizeFactor: _pass,
      child: Form(
        key: _passKey,
        child: SizedBox(
          width: _screen.width * 0.85,
          child: Column(
            children: [
              OutlinedTextField(
                key: ValueKey('password'),
                state: _emailKey,
                controller: _passC,
                hintText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                caps: TextCapitalization.none,
                maxLength: 20,
                validator: _validatePassword,
                obscure: true,
                style: _theme.textTheme.bodyText1,
              ),
              SizedBox(height: 10),
              if (_create)
                OutlinedTextField(
                  key: ValueKey('confirmPassword'),
                  state: _emailKey,
                  controller: _cPassC,
                  hintText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  caps: TextCapitalization.none,
                  maxLength: 20,
                  validator: _validateConfirm,
                  obscure: true,
                  style: _theme.textTheme.bodyText1,
                ),
              if (_create) SizedBox(height: 15),
              SizedBox(
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton.extended(
                      key: ValueKey('start-auth'),
                      label: _loading
                          ? SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(
                                backgroundColor: greySwatch[50],
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              _create ? 'SIGN UP' : 'SIGN IN',
                              style: _theme.textTheme.bodyText1?.copyWith(color: greySwatch[50]),
                            ),
                      elevation: 4,
                      backgroundColor: _theme.primaryColor,
                      onPressed: _authWithEmail,
                    ),
                    FloatingActionButton.extended(
                      key: ValueKey('cancel'),
                      label: Text(
                        'CANCEL',
                        style: _theme.textTheme.bodyText1?.copyWith(color: greySwatch[50]),
                      ),
                      elevation: 2,
                      backgroundColor: greySwatch[300],
                      onPressed: _reset,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
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
    return Row(
      children: [
        Expanded(
          child: OutlinedTextField(
            key: ValueKey('username'),
            state: _emailKey,
            controller: _emailC,
            hintText: 'Email address',
            prefixIcon: Icon(
              Icons.email,
            ),
            caps: TextCapitalization.none,
            maxLength: 50,
            validator: _validateEmail,
            style: _theme.textTheme.bodyText1,
          ),
        ),
        SizedBox(width: 10),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 50),
          child: FloatingActionButton(
            key: ValueKey('submitPhoneNumber'),
            onPressed: _startEmailFlow,
            child: Icon(Icons.arrow_upward),
            backgroundColor: _theme.primaryColor,
          ),
        ),
      ],
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
              SocialButton(method: SignInMethod.GOOGLE, onTap: _authWithSocial),
              SizedBox(width: 15),
              SocialButton(method: SignInMethod.FACEBOOK, onTap: _authWithSocial),
            ],
          ),
        ),
        SizedBox(height: 7.5),
        _showSocialError(),
      ],
    );
  }

  _buildSwap() {
    return SafeArea(
      bottom: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: swatch[400],
        ),
        padding: EdgeInsets.all(2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOption(true),
              SizedBox(width: 2),
              _buildOption(false),
            ],
          ),
        ),
      ),
    );
  }

  _buildOption(bool create) {
    return InkWell(
      onTap: () {
        _create = create;
        _reset();
      },
      child: Container(
        width: _screen.width * 0.175,
        padding: EdgeInsets.symmetric(vertical: 7.5),
        alignment: Alignment.center,
        color: _create == create ? Color(0x00000000) : greySwatch[50],
        child: Text(
          create ? 'SIGN UP' : 'SIGN IN',
          style: _theme.textTheme.caption?.copyWith(
            color: _create == create ? greySwatch[50] : _theme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _showSocialError() {
    final social = [SignInMethod.FACEBOOK, SignInMethod.GOOGLE].contains(_method);
    if (social) {
      switch (_status) {
        case AuthStatus.DUPLICATE:
          return _makeError('An account already exists. Try signing in!');
        case AuthStatus.ERROR:
          return _makeError('Something went wrong! Try again.');
        case AuthStatus.BLOCKED:
          return _makeError('This account has been blocked! Contact the admin!');
        case AuthStatus.NO_ACCOUNT:
          return _makeError('No account found! Try signing up!');
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

  _authWithEmail() {
    _onError(e) => _handleError(e, SignInMethod.EMAIL);
    if (_loading) return;
    widget.onDrop();
    _loading = true;
    if (_passKey.currentState?.validate() ?? false) {
      final data = EmailData(_emailC.text, _passC.text, _create);
      widget.service.authWithEmail(data).then(_onSuccess).catchError(_onError);
    } else {
      _loading = false;
    }
    setState(() {});
  }

  _authWithSocial(SignInMethod method) async {
    _onError(e) => _handleError(e, method);
    if (_loading) return;
    widget.onDrop();
    _loading = true;
    setState(() {});
    widget.service.authWithSocial(method, _create).then(_onSuccess).catchError(_onError);
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

  _handleError(Object exception, SignInMethod method) {
    Aspects.instance.log('AuthInitPage -> error');
    _loading = false;
    _method = method;
    switch (method) {
      case SignInMethod.GOOGLE:
      case SignInMethod.FACEBOOK:
        if (exception is PlatformException && exception.code == 'SIGN_IN_CANCELED') {
          Aspects.instance.log('Login -> $method -> Canceled');
        } else if (exception is LoginException) {
          Aspects.instance.log('Login -> $method -> Fail');
          switch (exception.status) {
            case 400:
              _status = _create ? AuthStatus.DUPLICATE : AuthStatus.NO_ACCOUNT;
              break;
            case 412:
              _status = AuthStatus.BLOCKED;
              break;
            default:
              _status = AuthStatus.ERROR;
          }
        } else {
          Aspects.instance.recordError(exception);
          _status = AuthStatus.ERROR;
        }
        break;
      case SignInMethod.EMAIL:
        if (exception is FirebaseAuthException) {
          switch (exception.code) {
            case 'wrong-password':
              _status = AuthStatus.INCORRECT_CREDS;
              break;
            case 'too-many-requests':
              _status = AuthStatus.BLOCKED;
              break;
            case 'email-already-in-use':
              _status = AuthStatus.DUPLICATE;
              break;
            case 'weak-password':
              _status = AuthStatus.WEAK_PASSWORD;
              break;
            case 'user-not-found':
              _status = AuthStatus.NO_ACCOUNT;
          }
        } else if (exception is LoginException) {
          Aspects.instance.log('Login -> $method -> Fail');
          switch (exception.status) {
            case 400:
              _status = _create ? AuthStatus.DUPLICATE : AuthStatus.NO_ACCOUNT;
              break;
            case 403:
              if (!_create) _status = AuthStatus.INCORRECT_CREDS;
              break;
            case 412:
              _status = AuthStatus.BLOCKED;
              break;
            default:
              _status = AuthStatus.ERROR;
          }
        } else {
          Aspects.instance.recordError(exception);
          _status = AuthStatus.ERROR;
        }
        _passKey.currentState?.validate();
    }
    setState(() {});
  }

  _startEmailFlow() {
    widget.onDrop();
    if (_emailKey.currentState?.validate() ?? false) _pass.forward();
  }

  _reset() {
    if (_pass.isCompleted) _pass.reverse();
    _emailC.text = '';
    _passC.text = '';
    _cPassC.text = '';
    _status = AuthStatus.NONE;
    _emailKey.currentState?.reset();
    _passKey.currentState?.reset();
    setState(() {});
  }

  String? _validateEmail(String? value) {
    value ??= '';
    if (!RegExp(eReg).hasMatch(value)) return 'Invalid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'Password cannot be empty';
    final oldStatus = _status;
    _status = AuthStatus.NONE;
    switch (oldStatus) {
      case AuthStatus.INCORRECT_CREDS:
        return 'Incorrect password/ login method!';
      case AuthStatus.BLOCKED:
        return 'This account has been blocked! Contact admin!';
      case AuthStatus.DUPLICATE:
        return 'This account already exists! Try signing in!';
      case AuthStatus.NO_ACCOUNT:
        return 'No account found';
      default:
        return null;
    }
  }

  String? _validateConfirm(String? value) {
    if (!_create) return null;
    return value == _passC.text ? null : 'Not the same as password';
  }
}
