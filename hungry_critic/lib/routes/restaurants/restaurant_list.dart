import 'package:flutter/material.dart';

import '../../blocs/restaurant.dart';
import '../../models/restaurant.dart';
import '../../shared/colors.dart';
import '../../shared/context.dart';
import '../../shared/star_selection.dart';
import 'restaurant_card.dart';

const options = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0];

class RestaurantList extends StatefulWidget {
  const RestaurantList({Key? key, required this.onUpdate}) : super(key: key);

  final Function(Restaurant) onUpdate;

  @override
  _RestaurantListState createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {
  late ThemeData _theme;

  late RestaurantBloc _bloc;

  double minRating = 0;
  double maxRating = 5;

  bool _filtering = false;

  bool _loading = false;
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _bloc = BlocsContainer.of(context).rBloc;
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
              Expanded(child: _buildRestaurants(data)),
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
            padding: const EdgeInsets.only(left: 12.5, bottom: 5, top: 5),
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
    if (!_filtering) return Container();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStar(
          minRating,
          () => options.where((o) => o <= maxRating).toList(),
          (m) => minRating = m,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            'to',
            style: _theme.textTheme.caption?.copyWith(color: swatch),
          ),
        ),
        _buildStar(
          maxRating,
          () => options.where((o) => o >= minRating).toList(),
          (m) => maxRating = m,
        ),
      ],
    );
  }

  _buildStar(
    double rating,
    List<double> Function() makeOptions,
    Function(double) onChange,
  ) {
    _selectOption() {
      final options = makeOptions();
      Navigator.of(context).push(StarSelectionRoute(options)).then((o) {
        if (o != null) {
          onChange(o);
          setState(() {});
        }
      });
    }

    return InkWell(
      onTap: _selectOption,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.5),
          color: swatch[300],
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$rating',
              style: _theme.textTheme.bodyText1?.copyWith(color: greySwatch[50]),
            ),
            SizedBox(width: 3),
            Icon(Icons.star, color: greySwatch[50], size: 17.5),
            SizedBox(width: 3),
            Icon(Icons.edit, size: 20, color: greySwatch[50]),
          ],
        ),
      ),
    );
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

  Widget _buildRestaurants(List<String> ids) {
    if (ids.isEmpty) {
      return Center(
        child: Text(
          'No restaurants yet!',
          style: _theme.textTheme.subtitle1?.copyWith(color: greySwatch[600]),
          textAlign: TextAlign.center,
        ),
      );
    }
    final rs = ids
        .map(_bloc.find)
        .whereType<Restaurant>()
        .where((r) => r.averageRating >= minRating && r.averageRating <= maxRating)
        .toList();
    return ListView.builder(
      controller: _controller,
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
