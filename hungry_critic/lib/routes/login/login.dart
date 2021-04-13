import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../blocs/account.dart';
import '../../services/sign_in.dart';
import 'auth_init_page.dart';

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
  late ThemeData _theme;

  late SignUpService _service;

  final _controller = PageController(keepPage: false);
  bool _needsAuth = true;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: _theme.primaryColorLight,
          ),
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
                );
                final pageMap = {0: one};
                return pageMap[index] ?? one;
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> initProfile() async {
    setState(() {
      _needsAuth = false;
    });
    nextPage();
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
    _needsAuth = true;
    setState(() {});
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }
}
