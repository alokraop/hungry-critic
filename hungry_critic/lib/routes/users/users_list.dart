import 'package:flutter/material.dart';
import 'package:hungry_critic/models/account.dart';

class UsersList extends StatefulWidget {
  UsersList({Key? key, required this.onUpdate}) : super(key: key);

  final Function([Account]) onUpdate;

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
