import 'package:flutter/material.dart';
import 'package:hungry_critic/flaps/creation_flap.dart';

import '../../blocs/account.dart';
import '../../blocs/users.dart';
import '../../models/account.dart';
import '../../shared/colors.dart';
import '../../shared/context.dart';
import 'user_card.dart';

class UsersList extends StatefulWidget {
  UsersList({Key? key, required this.onUpdate}) : super(key: key);

  final Function([Account]) onUpdate;

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  late UserBloc _bloc;
  late AccountBloc _aBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocsContainer.of(context).uBloc;
    _aBloc = BlocsContainer.of(context).aBloc;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder(
      stream: _bloc.users,
      initialData: <String>[],
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        final data = snapshot.data;
        if (data == null) return Container();
        return SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.5, top: 7.5, bottom: 15),
                    child: Text(
                      'Users',
                      style: theme.textTheme.headline5?.copyWith(
                        fontWeight: FontWeight.w300,
                        color: swatch[600],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(child: _buildRecords(data)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecords(List<String> ids) {
    final us = ids.map(_bloc.find).whereType<Account>().toList();
    return ListView.builder(
      itemCount: us.length,
      itemBuilder: (context, index) {
        final user = us[index];
        return UserCard(user: user, onUpdate: () => _startUpdate(user));
      },
    );
  }

  _startUpdate(Account user) {
    Navigator.of(context).push(CreateEntity(type: Entity.USER, entity: user));
  }
}
