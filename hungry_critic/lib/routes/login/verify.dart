import 'package:flutter/material.dart';

import '../../models/account.dart';
import '../../services/sign_in.dart';
import '../../shared/colors.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({
    Key? key,
    required this.service,
    required this.onDone,
    required this.onCancel,
  }) : super(key: key);

  final SignUpService service;

  final Function(bool) onDone;

  final Function() onCancel;

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  late ThemeData _theme;

  bool _fail = false;

  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Container(
          color: swatch[400],
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: _buildContent(screen),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: BackButton(onPressed: widget.onCancel),
        ),
      ],
    );
  }

  Column _buildContent(Size screen) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/tick.png',
          width: screen.width * 0.15,
        ),
        Text(
          'Verification email sent',
          style: _theme.textTheme.subtitle2?.copyWith(color: greySwatch[50]),
        ),
        SizedBox(height: 10),
        _fail
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    color: greySwatch[50],
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Your email hasn\'t yet been verified!',
                    style: _theme.textTheme.subtitle2?.copyWith(color: greySwatch[50]),
                    textAlign: TextAlign.center,
                  )
                ],
              )
            : Text(
                'You can proceed after you verify your email address',
                style: _theme.textTheme.subtitle2?.copyWith(color: greySwatch[50]),
                textAlign: TextAlign.center,
              ),
        SizedBox(height: 15),
        FloatingActionButton.extended(
          label: _loading
              ? SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  _fail ? 'TRY AGAIN' : 'ALL DONE',
                  style: _theme.textTheme.subtitle2?.copyWith(color: _theme.primaryColor),
                ),
          backgroundColor: greySwatch[50],
          onPressed: _fetchToken,
        )
      ],
    );
  }

  _fetchToken() async {
    setState(() => _loading = true);
    final status = await widget.service.retryAuth();
    switch (status) {
      case AuthStatus.NEW_ACCOUNT:
        widget.onDone(true);
        break;
      case AuthStatus.EXISTING_ACCOUNT:
        widget.onDone(false);
        break;
      case AuthStatus.UNVERIFIED:
        _loading = false;
        _fail = true;
        setState(() {});
        break;
      default:
        widget.onCancel();
    }
  }
}
