import 'dart:async';

import 'package:flutter/material.dart';

import '../blocs/account.dart';
import '../blocs/users.dart';
import '../models/account.dart';
import '../shared/colors.dart';
import '../shared/context.dart';
import 'creation_flap.dart';

class UserForm extends StatefulWidget {
  UserForm({Key? key, required this.user}) : super(key: key);

  final Account user;

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends EntityCreator<UserForm> {
  late ThemeData _theme;
  late Size _screen;

  late UserBloc _bloc;
  late AccountBloc _aBloc;

  final _nameC = TextEditingController();
  bool _initialized = true;
  bool _blocked = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameC.text = widget.user.name ?? '';
    final settings = widget.user.settings;
    _initialized = settings.initialized;
    _blocked = settings.blocked;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _screen = MediaQuery.of(context).size;

    final c = BlocsContainer.of(context);
    _bloc = c.uBloc;
    _aBloc = c.aBloc;
  }

  bool get self => widget.user.id == _aBloc.account.id;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _screen.width * 0.15),
        child: Column(
          children: [
            Text(
              'Update Info',
              style: _theme.textTheme.headline5?.copyWith(
                color: swatch,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _nameC,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: 'A name...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5),
                  borderSide: BorderSide(width: 1.5, color: greySwatch[300]),
                ),
                
              ),
              validator: _validateName,
            ),
            if (!self) _buildOptions(),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  _buildOptions() {
    final settings = widget.user.settings;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 15),
        if (!settings.initialized)
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activate:',
                  style: _theme.textTheme.bodyText1,
                ),
                _buildOptionSet(_initialized, (i) => setState(() => _initialized = i)),
              ],
            ),
          ),
        if (settings.initialized)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Block:',
                style: _theme.textTheme.bodyText1,
              ),
              _buildOptionSet(_blocked, (i) => setState(() => _blocked = i)),
            ],
          ),
      ],
    );
  }

  _buildOptionSet(bool yes, Function(bool) onToggle) {
    return Container(
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
            _buildOption('YES', yes, () => onToggle(true)),
            SizedBox(width: 2),
            _buildOption('NO', !yes, () => onToggle(false)),
          ],
        ),
      ),
    );
  }

  _buildOption(String label, bool active, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: _screen.width * 0.15,
        padding: EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        color: active ? Color(0x00000000) : greySwatch[50],
        child: Text(
          label,
          style: _theme.textTheme.caption?.copyWith(
            color: active ? greySwatch[50] : _theme.primaryColor,
          ),
        ),
      ),
    );
  }

  String? _validateName(String? name) {
    if (name?.isEmpty ?? true) return 'You need to give a name';
    return null;
  }

  @override
  FutureOr<SubmitStatus> submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return SubmitStatus.INVALID;

    final settings = widget.user.settings;
    final user = widget.user.copyWith(
      name: _nameC.text,
      settings: settings.copyWith(
        initialized: _initialized,
        blocked: _blocked,
      ),
    );
    if (user.id == _aBloc.account.id) {
      return _aBloc
          .update(user)
          .then((_) => SubmitStatus.SUCCESS)
          .catchError((_) => SubmitStatus.FAIL);
    } else {
      return _bloc
          .update(user)
          .then((_) => SubmitStatus.SUCCESS)
          .catchError((_) => SubmitStatus.FAIL);
    }
  }
}
