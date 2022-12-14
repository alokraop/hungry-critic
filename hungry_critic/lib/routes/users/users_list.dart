import 'package:flutter/material.dart';

import '../../blocs/users.dart';
import '../../flaps/creation_flap.dart';
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

  late ThemeData _theme;

  final _controller = ScrollController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  _onScroll() {
    if (!_loading) {
      final max = _controller.position.maxScrollExtent;
      final scrolled = _controller.offset + _controller.position.extentInside;
      final fraction = scrolled / max;
      if (fraction > 0.6) _loadMore();
    }
  }

  Future _loadMore() async {
    _loading = true;
    final hasMore = await _bloc.loadMore();
    _loading = !hasMore;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _bloc = BlocsContainer.of(context).uBloc;
  }

  @override
  Widget build(BuildContext context) {
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
                      style: _theme.textTheme.headline5?.copyWith(
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
    if (ids.isEmpty) {
      return Center(
        child: Text(
          'No users yet!',
          style: _theme.textTheme.subtitle1?.copyWith(color: greySwatch[600]),
          textAlign: TextAlign.center,
        ),
      );
    }
    final us = ids.map(_bloc.find).whereType<Account>().toList();
    return ListView.builder(
      controller: _controller,
      itemCount: us.length,
      itemBuilder: (context, index) {
        final user = us[index];
        return UserCard(
          user: user,
          onUpdate: () => _startUpdate(user),
          onDelete: () => _startDelete(user),
        );
      },
    );
  }

  _startUpdate(Account user) {
    Navigator.of(context).push(CreateEntity(type: Entity.USER, entity: user));
  }

  _startDelete(Account user) {
    _showDialog(
      'All their restaurants, reviews, and replies will be deleted',
      () => _bloc.delete(user),
    );
  }

  _showDialog(String content, Function() onConfirm) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text(
          content,
          style: _theme.textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w300),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text('YES'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: Text('NO'),
          ),
        ],
      ),
    );
  }
}
