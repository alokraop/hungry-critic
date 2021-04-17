import 'package:flutter/material.dart';

import '../../blocs/restaurant.dart';
import '../../models/restaurant.dart';
import '../../shared/colors.dart';
import '../../shared/context.dart';
import 'restaurant_card.dart';

class RestaurantList extends StatefulWidget {
  const RestaurantList({Key? key, required this.onUpdate}) : super(key: key);

  final Function(Restaurant) onUpdate;

  @override
  _RestaurantListState createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {
  late ThemeData _theme;

  late RestaurantBloc _bloc;

  int minRating = 0;
  int maxRating = 5;

  bool _filtering = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _bloc = BlocsContainer.of(context).rBloc;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bloc.restaurants,
      initialData: <String>[],
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        final data = snapshot.data;
        if (data == null) return Container();
        return SafeArea(
          child: Column(
            children: [
              if (data.isNotEmpty) _buildOptions(),
              Expanded(child: _buildRecords(data)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptions() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 12.5),
            child: Text(
              'Restaurants',
              style: _theme.textTheme.headline5?.copyWith(
                fontWeight: FontWeight.w300,
                color: swatch[600],
              ),
            ),
          ),
        ),
        _buildRange(),
        _buildActions(),
      ],
    );
  }

  _buildRange() {
    return Container();
  }

  _buildActions() {
    return InkWell(
      onTap: _toggleFilter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.5, vertical: 12.5),
        child: Icon(
          _filtering ? Icons.filter_alt : Icons.filter_alt_outlined,
          color: _filtering ? swatch : greySwatch[400],
          size: 30,
        ),
      ),
    );
  }

  _toggleFilter() {
    minRating = 0;
    maxRating = 5;
    _filtering = !_filtering;
    setState(() {});
  }

  Widget _buildRecords(List<String> ids) {
    final rs = ids
        .map(_bloc.find)
        .whereType<Restaurant>()
        .where((r) => r.averageRating >= minRating && r.averageRating <= maxRating)
        .toList();
    return ListView.builder(
      itemCount: rs.length,
      itemBuilder: (context, index) {
        final restaurant = rs[index];
        return RestaurantCard(
          restaurant: restaurant,
          onTap: _showRestaurant,
        );
      },
    );
  }

  _showRestaurant(Restaurant restaurant) {
    Navigator.of(context).pushNamed('/restaurant', arguments: restaurant);
  }
}
