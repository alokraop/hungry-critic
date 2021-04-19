import 'package:flutter/material.dart';
import 'package:hungry_critic/blocs/account.dart';
import 'package:hungry_critic/shared/colors.dart';
import 'package:hungry_critic/shared/context.dart';

class BlockedScreen extends StatefulWidget {
  const BlockedScreen({Key? key, required this.onLogout}) : super(key: key);

  final Function() onLogout;

  @override
  _BlockedScreenState createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  late ThemeData _theme;
  late AccountBloc _bloc;

  bool _fail = false;

  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _bloc = BlocsContainer.of(context).aBloc;
  }

  @override
  Widget build(BuildContext context) {
    final settings = _bloc.account.settings;
    return Container(
      color: swatch[400],
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            settings.blocked
                ? 'This account has been blocked!'
                : 'This account needs to be activated!',
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
                      'Your admin hasn\'t allowed it yet!',
                      style: _theme.textTheme.subtitle2?.copyWith(color: greySwatch[50]),
                      textAlign: TextAlign.center,
                    )
                  ],
                )
              : Text(
                  'You can proceed after your admin allows it',
                  style: _theme.textTheme.subtitle2?.copyWith(color: greySwatch[50]),
                  textAlign: TextAlign.center,
                ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
                        _fail ? 'TRY AGAIN' : 'REFRESH',
                        style: _theme.textTheme.subtitle2?.copyWith(color: _theme.primaryColor),
                      ),
                backgroundColor: greySwatch[50],
                onPressed: _fetchToken,
              ),
              FloatingActionButton.extended(
                label: Text(
                  'LOGOUT',
                  style: _theme.textTheme.subtitle2?.copyWith(color: _theme.primaryColor),
                ),
                backgroundColor: greySwatch[50],
                onPressed: widget.onLogout,
              ),
            ],
          ),
        ],
      ),
    );
  }

  _fetchToken() async {
    setState(() => _loading = true);
    await _bloc.refreshAccount();
    if (_bloc.isBlocked) {
      _loading = false;
      _fail = true;
      setState(() {});
    }
  }
}
