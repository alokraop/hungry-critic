import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../blocs/account.dart';
import '../../blocs/restaurant.dart';
import '../../flaps/creation_flap.dart';
import '../../models/account.dart';
import '../../models/restaurant.dart';
import '../../shared/colors.dart';
import '../../shared/context.dart';
import '../../shared/loader.dart';
import '../../shared/popup.dart';
import 'common.dart';

const background = Color(0xffe8e8e8);

class RestaurantDetails extends StatefulWidget {
  RestaurantDetails({Key? key, required this.restaurant}) : super(key: key);

  final Restaurant restaurant;

  @override
  _RestaurantDetailsState createState() => _RestaurantDetailsState();
}

class _RestaurantDetailsState extends State<RestaurantDetails> {
  late ThemeData _theme;
  late RestaurantBloc _bloc;
  late AccountBloc _aBloc;

  late Restaurant _restaurant;

  StreamSubscription<List<String>>? _sub;

  bool _highlights = true;

  bool get canModify {
    final account = _aBloc.account;
    switch (account.role) {
      case UserRole.ADMIN:
        return true;
      case UserRole.CUSTOMER:
        return false;
      case UserRole.OWNER:
        return account.id == widget.restaurant.owner;
    }
  }

  bool get canReview => _aBloc.account.role == UserRole.CUSTOMER;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sub == null) {
      _restaurant = widget.restaurant;
      _sub = _bloc.restaurants.listen((_) {
        final restaurant = _bloc.find(_restaurant.id);
        if (restaurant != null) _restaurant = restaurant;
      });
    }
    _theme = Theme.of(context);
    _bloc = BlocsContainer.of(context).rBloc;
    _aBloc = BlocsContainer.of(context).aBloc;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: greySwatch[50],
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                _buildForehead(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 25, left: 10),
                    child: Column(
                      children: [
                        _buildInfo(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Divider(thickness: 0.75),
                        ),
                        _buildLocation(),
                        _buildTimings(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Divider(thickness: 0.75),
                        ),
                        Expanded(child: _buildReviews()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _buildForehead(),
          ],
        ),
        floatingActionButton: canReview
            ? FloatingActionButton.extended(
                onPressed: _startReview,
                icon: Icon(Icons.edit),
                label: Text(
                  'REVIEW',
                  style: _theme.textTheme.bodyText1?.copyWith(
                    color: greySwatch[50],
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  _buildForehead() {
    return Container(
      decoration: BoxDecoration(
        color: swatch,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 3),
            blurRadius: 2,
            color: greySwatch[700].withOpacity(0.3),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 5),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            BackButton(
              color: greySwatch[50],
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: greySwatch[50],
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.bookmark,
                      color: greySwatch[50],
                    ),
                    onPressed: () {},
                  ),
                  if (canModify)
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: greySwatch[50],
                      ),
                      onPressed: _startEdit,
                    ),
                  if (canModify)
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: greySwatch[50],
                      ),
                      onPressed: _startDelete,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildInfo() {
    return Row(
      children: [
        SizedBox(width: 5),
        Expanded(child: _buildTitle()),
        _buildRating(),
      ],
    );
  }

  _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _restaurant.name,
          style: _theme.textTheme.headline4
              ?.copyWith(fontWeight: FontWeight.w500, color: greySwatch[900]),
        ),
        Text(
          _restaurant.cuisines.join(', '),
          style: _theme.textTheme.bodyText2,
        ),
      ],
    );
  }

  _buildRating() {
    return Container(
      decoration: BoxDecoration(
        color: findColor(_restaurant.averageRating),
        borderRadius: BorderRadius.horizontal(left: Radius.circular(12.5)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.5, vertical: 7.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _restaurant.averageRating.toStringAsFixed(1),
            style: _theme.textTheme.headline6?.copyWith(color: greySwatch[50]),
          ),
          SizedBox(width: 5),
          Icon(Icons.star, color: greySwatch[50], size: 18),
        ],
      ),
    );
  }

  _buildLocation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.room_outlined,
                  size: 22,
                  color: greySwatch[400],
                ),
              ),
              Text(
                'Location',
                style: _theme.textTheme.bodyText1?.copyWith(
                  color: greySwatch[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Directions',
                      style: _theme.textTheme.caption?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: swatch,
                      ),
                    ),
                    SizedBox(width: 15),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 5),
            child: Text(
              _restaurant.address ?? 'Unknown!',
              style: _theme.textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildTimings() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.schedule,
                  size: 20,
                  color: greySwatch[400],
                ),
              ),
              Text(
                'Timings',
                style: _theme.textTheme.bodyText1?.copyWith(
                  color: greySwatch[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.call_outlined, color: swatch),
                    SizedBox(width: 15),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 5),
            child: Text(
              '11 AM to 1 AM',
              style: _theme.textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildReviews() {
    return Column(
      children: [
        Container(
          height: 50,
          margin: EdgeInsets.only(right: 15),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: GestureDetector(
                  onTap: () => setState(() => _highlights = true),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: _highlights ? swatch : background,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'HIGHLIGHTS',
                      style: _theme.textTheme.bodyText1?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: greySwatch[_highlights ? 50 : 400],
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: GestureDetector(
                  onTap: () => setState(() => _highlights = false),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: _highlights ? background : swatch,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'REVIEWS',
                      style: _theme.textTheme.bodyText1?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: greySwatch[_highlights ? 400 : 50],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _startEdit() {
    Navigator.of(context).push(
      CreateEntity(entity: _restaurant, restaurant: true),
    );
  }

  _startDelete() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text(
          'This will delete the restaurant and all its reviews',
          style: _theme.textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w300),
        ),
        actions: [
          TextButton(
            onPressed: () => _delete(),
            child: Text('DELETE'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  _delete() async {
    Navigator.of(context).pop();
    Navigator.of(context).push(LoaderRoute('Deleting Restaurant...'));
    await _bloc.deleteRestaurant(widget.restaurant).catchError(
          (_) => Navigator.of(context).pushReplacement(
            IconRoute(
              Icon(Icons.error_outline, color: _theme.errorColor),
              'Failed! Please try again!',
            ),
          ),
        );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  _startReview() {
    Navigator.of(context).push(
      CreateEntity(entity: _restaurant, restaurant: true),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
