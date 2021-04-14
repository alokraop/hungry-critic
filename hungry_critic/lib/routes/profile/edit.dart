import 'package:flutter/material.dart';

import '../../blocs/account.dart';
import '../../models/account.dart';
import '../../shared/colors.dart';
import '../../shared/context.dart';
import '../../shared/custom_text_fields.dart';

class EditPage extends StatefulWidget {
  const EditPage({Key? key}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late AccountBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocsContainer.of(context).aBloc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greySwatch[50],
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            EditProfile(
              key: ValueKey('editProfileRoute'),
              bloc: _bloc,
              onDone: _goBack,
            ),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Icon(
                  Icons.clear,
                  size: 27.5,
                  color: greySwatch[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _goBack() {
    Navigator.of(context).pop();
  }
}

class EditProfile extends StatefulWidget {
  const EditProfile({
    Key? key,
    required this.bloc,
    required this.onDone,
  }) : super(key: key);

  final AccountBloc bloc;

  final Function() onDone;

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late ThemeData _theme;
  late Size _screen;
  final _formKey = GlobalKey<FormState>();

  final _nameC = TextEditingController();

  UserRole _role = UserRole.CUSTOMER;

  var _mode = AutovalidateMode.disabled;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final account = widget.bloc.account;
    _nameC.text = account.name ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _screen = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      autovalidateMode: _mode,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screen.width * 0.125),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your info:', style: _theme.textTheme.headline5),
            SizedBox(height: 12.5),
            UnderlinedTextField(
              state: _formKey,
              controller: _nameC,
              hintText: 'Your name',
              prefixIcon: Icon(
                Icons.people,
                color: _theme.primaryColor,
              ),
              caps: TextCapitalization.none,
              maxLength: 30,
              validator: _validateName,
            ),
            SizedBox(height: 10),
            _buildRole(),
            SizedBox(height: 25),
            FloatingActionButton.extended(
              key: ValueKey('save-changes'),
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: _loading
                    ? SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          backgroundColor: greySwatch[50],
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'SAVE CHANGES',
                        style: _theme.textTheme.bodyText1?.copyWith(color: greySwatch[50]),
                      ),
              ),
              elevation: 2,
              onPressed: _saveChanges,
            ),
          ],
        ),
      ),
    );
  }

  _buildRole() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: _theme.primaryColor,
      ),
      padding: EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption(UserRole.CUSTOMER, 'USER'),
            SizedBox(width: 2),
            _buildOption(UserRole.OWNER, 'OWNER'),
          ],
        ),
      ),
    );
  }

  _buildOption(UserRole role, String label) {
    return InkWell(
      onTap: () => setState(() => _role = role),
      child: Container(
        width: _screen.width * 0.2,
        padding: EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.center,
        color: _role == role ? _theme.primaryColor : greySwatch[50],
        child: Text(
          label,
          style: _theme.textTheme.caption?.copyWith(
            color: _role == role ? greySwatch[50] : _theme.primaryColor,
          ),
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value?.isEmpty ?? false) return 'We need a name';
    return null;
  }

  Future _saveChanges() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _loading = true);
      final account = widget.bloc.account;
      return widget.bloc
          .update(account.copyWith(name: _nameC.text, role: _role))
          .then((_) => widget.onDone());
    } else {
      setState(() => _mode = AutovalidateMode.onUserInteraction);
    }
  }
}
