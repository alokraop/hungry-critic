import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../blocs/account.dart';
import '../blocs/restaurant.dart';
import '../models/restaurant.dart';
import '../shared/colors.dart';
import '../shared/context.dart';
import '../shared/custom_text_fields.dart';
import 'creation_flap.dart';

final cuisines = [
  'American',
  'Arabic',
  'Brazilian',
  'Chinese',
  'French',
  'Fast Food',
  'Goan',
  'Hyderabadi',
  'Indian (North)',
  'Indian (South)',
  'Indonesian',
  'Italian',
  'Japanese',
  'Malasiyan',
  'Mexican',
  'Mediterranian',
  'Pakistani',
  'Russian',
  'Vietnamese',
];

class RestaurantForm extends StatefulWidget {
  RestaurantForm({Key? key, this.restaurant, required this.updateFlap}) : super(key: key);

  final Restaurant? restaurant;

  final Function(Widget?) updateFlap;

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
  final _addC = TextEditingController();

  final _cuisines = <String>[];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final restaurant = widget.restaurant;
    id = restaurant?.id ?? Uuid().v4();
    if (restaurant != null) {
      _nameC.text = restaurant.name;
      _addC.text = restaurant.address ?? '';
      _cuisines.addAll(restaurant.cuisines);
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
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _screen.width * 0.15),
        child: Column(
          children: [
            Text(
              widget.restaurant != null ? 'Update Restaurant' : 'Create Restaurant',
              style: _theme.textTheme.headline5?.copyWith(
                color: swatch,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 15),
            UnderlinedTextField(
              hintText: 'A Name',
              controller: _nameC,
              style: _theme.textTheme.bodyText1,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
            ),
            SizedBox(height: 20),
            UnderlinedTextField(
              hintText: 'An Address',
              controller: _addC,
              style: _theme.textTheme.bodyText1,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CUISINES',
                    style: _theme.textTheme.caption?.copyWith(color: swatch[400]),
                  ),
                  _cuisines.length < 3
                      ? InkWell(
                          child: SizedBox(
                            height: 40,
                            child: Icon(Icons.add, color: swatch[500]),
                          ),
                          onTap: _pickCuisine,
                        )
                      : SizedBox(height: 40),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10),
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: _cuisines.map(_buildCuisine).toList(),
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildCuisine(String cuisine) {
    removeCuisine() {
      setState(() => _cuisines.remove(cuisine));
    }

    return InkWell(
      onTap: removeCuisine,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: swatch[300],
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 1.5),
              child: Text(
                cuisine,
                style: _theme.textTheme.caption?.copyWith(color: greySwatch[50]),
              ),
            ),
            SizedBox(width: 5),
            Icon(Icons.clear, color: greySwatch[50], size: 15),
          ],
        ),
      ),
    );
  }

  _pickCuisine() {
    final unselected = cuisines.where((i) => !_cuisines.contains(i)).toList();
    final content = Container(
      constraints: BoxConstraints(maxHeight: _screen.height * 0.25),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: unselected.map(_buildCLabel).toList(),
        ),
      ),
    );
    widget.updateFlap(content);
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  Widget _buildCLabel(String label) {
    return InkWell(
      onTap: () => _addCuisine(label),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: Text(
          label,
          style: _theme.textTheme.bodyText1?.copyWith(color: greySwatch[50]),
        ),
      ),
    );
  }

  _addCuisine(String label) {
    _cuisines.add(label);
    widget.updateFlap(null);
    setState(() {});
  }

  @override
  FutureOr<SubmitStatus> submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return SubmitStatus.INVALID;
    final restaurant = Restaurant(
      id: id,
      owner: _aBloc.account.id,
      name: _nameC.text,
      address: _addC.text,
      cuisines: _cuisines,
    );
    if (widget.restaurant == null) {
      return _bloc
          .createNew(restaurant)
          .then((_) => SubmitStatus.SUCCESS)
          .catchError((_) => SubmitStatus.FAIL);
    } else {
      return _bloc
          .update(restaurant)
          .then((_) => SubmitStatus.SUCCESS)
          .catchError((_) => SubmitStatus.FAIL);
    }
  }
}
