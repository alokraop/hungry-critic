import 'package:flutter/material.dart';
import 'package:hungry_critic/routes/restaurants/common.dart';
import 'package:hungry_critic/shared/colors.dart';

import '../../models/restaurant.dart';

class RestaurantCard extends StatefulWidget {
  RestaurantCard({
    Key? key,
    required this.restaurant,
    this.onTap,
  }) : super(key: key);

  final Restaurant restaurant;

  final Function(Restaurant)? onTap;

  @override
  _RestaurantCardState createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => widget.onTap?.call(widget.restaurant),
      child: Container(
        margin: EdgeInsets.only(left: 12.5, right: 12.5, bottom: 20),
        decoration: BoxDecoration(
          color: greySwatch[50],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: greySwatch[800].withOpacity(0.4),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: _buildCard(theme),
      ),
    );
  }

  Widget _buildCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: greySwatch[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildName(theme)),
              _buildRating(theme),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              widget.restaurant.address ?? 'Unknown location!',
              style: theme.textTheme.bodyText2?.copyWith(color: greySwatch[600]),
            ),
          ),
          SizedBox(height: 5),
          Wrap(
            spacing: 5,
            runSpacing: 10,
            children: widget.restaurant.cuisines.map((c) => _buildBadge(theme, c)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildName(ThemeData theme) {
    return Text(
      widget.restaurant.name,
      style: theme.textTheme.headline6,
    );
  }

  Widget _buildRating(ThemeData theme) {
    final rating = widget.restaurant.averageRating;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      constraints: BoxConstraints(minWidth: 30),
      decoration: BoxDecoration(
        color: findColor(rating),
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: Text(
        rating == 0 ? '-' : rating.toStringAsFixed(1),
        style: theme.textTheme.subtitle1?.copyWith(color: greySwatch[50]),
      ),
    );
  }

  Widget _buildBadge(ThemeData theme, String label) {
    return Container(
      decoration: BoxDecoration(
        color: swatch[300],
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      child: Text(
        label,
        style: theme.textTheme.caption?.copyWith(color: greySwatch[50]),
      ),
    );
  }
}
