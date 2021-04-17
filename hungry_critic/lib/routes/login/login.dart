import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../blocs/account.dart';
import '../../services/sign_in.dart';
import 'profile.dart';
import 'creds.dart';
import 'verify.dart';

class LoginScreens extends StatefulWidget {
  final AccountBloc bloc;

  final Function() onLogin;

  const LoginScreens({Key? key, required this.bloc, required this.onLogin}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoginScreensState();
  }
}

class _LoginScreensState extends State<LoginScreens> {
  late SignUpService _service;

  final _controller = PageController(keepPage: false);
  bool _needsVerify = true;

  final _node = FocusNode();

  @override
  void initState() {
    super.initState();
    _initService();
  }

  _initService() {
    _service = SignUpService(widget.bloc);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          child: GestureDetector(
            onTap: _dropKeyboard,
            child: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: _controller,
              itemCount: 3,
              itemBuilder: (context, index) {
                final one = AuthInitPage(
                  service: _service,
                  onManual: nextPage,
                  onAuto: initProfile,
                  onDrop: _dropKeyboard,
                );
                final two = VerifyScreen(
                  service: _service,
                  onDone: initProfile,
                  onCancel: restart,
                );
                final three = EditTab(bloc: widget.bloc, onDone: doLogin, onCancel: restart);
                final pageMap = {
                  0: one,
                  1: _needsVerify ? two : three,
                  2: three,
                };
                return pageMap[index] ?? one;
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> initProfile(bool fresh) async {
    if (fresh) {
      setState(() => _needsVerify = false);
      nextPage();
    } else {
      doLogin();
    }
  }

  doLogin() async {
    widget.onLogin();
  }

  nextPage() {
    final page = _controller.page?.round() ?? 0;
    goToPage(page + 1);
  }

  goToPage(int page) {
    _controller.animateToPage(
      page,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  _dropKeyboard() {
    FocusScope.of(context).requestFocus(_node);
  }

  restart() async {
    _controller.jumpToPage(0);
    _needsVerify = true;
    setState(() {});
  }
}
