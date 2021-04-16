import 'package:flutter/material.dart';
import 'package:hungry_critic/models/restaurant.dart';

class RestaurantsList extends StatefulWidget {
  RestaurantsList({Key? key, required this.onUpdate}) : super(key: key);

  final Function([Restaurant]) onUpdate;

  @override
  _RestaurantsListState createState() => _RestaurantsListState();
}

class _RestaurantsListState extends State<RestaurantsList> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
