import 'package:flutter/material.dart';
import 'package:hungry_critic/flaps/creation_flap.dart';

import '../blocs/account.dart';
import '../models/account.dart';
import '../shared/colors.dart';
import '../shared/context.dart';

const _roleMap = {
  UserRole.USER: 'Customer',
  UserRole.OWNER: 'Owner',
  UserRole.ADMIN: 'Admin',
};

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.onLogout}) : super(key: key);

  final Function() onLogout;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late AccountBloc _bloc;
  late ThemeData _theme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocsContainer.of(context).aBloc;
    _theme = Theme.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 20),
        child: StreamBuilder(
          stream: _bloc.accountStream,
          initialData: _bloc.account,
          builder: (BuildContext context, AsyncSnapshot<Account> snapshot) {
            final account = snapshot.data;
            final name = account?.name;
            final email = account?.email;
            final role = _roleMap[account?.role];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('MY PROFILE', style: _theme.textTheme.headline5),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 45,
                      height: 45,
                      child: FloatingActionButton(
                        heroTag: 'edit-profile',
                        child: Icon(Icons.edit, color: greySwatch[50]),
                        onPressed: _editProfile,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (name != null) _buildCard('NAME', name),
                if (email != null) _buildCard('EMAIL', email),
                if (role != null) _buildCard('ROLE', role),
                SizedBox(height: 20),
                TextButton(
                  child: Text(
                    'LOGOUT',
                    style: _theme.textTheme.subtitle1?.copyWith(
                      color: _theme.errorColor,
                    ),
                  ),
                  onPressed: _startLogout,
                )
              ],
            );
          },
        ),
      ),
    );
  }

  _buildCard(String label, String value) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12.5),
      decoration: BoxDecoration(
        color: greySwatch[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: _theme.textTheme.subtitle1?.copyWith(color: _theme.primaryColor),
            ),
          ),
          SizedBox(width: 7.5),
          Text(value, style: _theme.textTheme.bodyText1),
        ],
      ),
    );
  }

  _editProfile() {
    Navigator.of(context).push(
      CreateEntity(type: Entity.USER, entity: _bloc.account),
    );
  }

  _startLogout() async {
    await _bloc.logout();
    widget.onLogout();
  }
}
