import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../blocs/account.dart';
import '../blocs/restaurant.dart';
import '../models/restaurant.dart';
import '../shared/context.dart';
import 'creation_flap.dart';

class RestaurantForm extends StatefulWidget {
  RestaurantForm({Key? key, this.restaurant}) : super(key: key);

  final Restaurant? restaurant;

  @override
  _RestaurantFormState createState() => _RestaurantFormState();
}

class _RestaurantFormState extends EntityCreator<RestaurantForm> {
  late ThemeData _theme;
  late Size _screen;

  late RestaurantBloc _bloc;
  late AccountBloc _aBloc;

  late String id;

  final _nameC = TextEditingController();

  @override
  void initState() {
    super.initState();
    final restaurant = widget.restaurant;
    id = restaurant?.id ?? Uuid().v4();
    if (restaurant != null) {
      _nameC.text = restaurant.name;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _screen = MediaQuery.of(context).size;

    final c = BlocsContainer.of(context);
    _bloc = c.rBloc;
    _aBloc = c.aBloc;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: _screen.width * 0.1,
      ),
      child: Column(
        children: [],
      ),
    );
  }

  @override
  Future<bool> createEntity() async {
    return false;
  }
}
