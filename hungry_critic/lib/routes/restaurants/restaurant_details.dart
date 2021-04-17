import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hungry_critic/models/restaurant.dart';
import 'package:hungry_critic/routes/restaurants/common.dart';
import 'package:hungry_critic/shared/colors.dart';

const background = Color(0xffe8e8e8);

class RestaurantDetails extends StatefulWidget {
  RestaurantDetails({Key? key, required this.restaurant}) : super(key: key);

  final Restaurant restaurant;

  @override
  _RestaurantDetailsState createState() => _RestaurantDetailsState();
}

class _RestaurantDetailsState extends State<RestaurantDetails> {
  late ThemeData _theme;

  bool _highlights = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
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
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: greySwatch[50],
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: greySwatch[50],
                    ),
                    onPressed: () {},
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
    final restaurant = widget.restaurant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          restaurant.name,
          style: _theme.textTheme.headline4
              ?.copyWith(fontWeight: FontWeight.w500, color: greySwatch[900]),
        ),
        Text(
          restaurant.cuisines.join(', '),
          style: _theme.textTheme.bodyText2,
        ),
      ],
    );
  }

  _buildRating() {
    final restaurant = widget.restaurant;
    return Container(
      decoration: BoxDecoration(
        color: findColor(restaurant.averageRating),
        borderRadius: BorderRadius.horizontal(left: Radius.circular(12.5)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.5, vertical: 7.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            restaurant.averageRating.toStringAsFixed(1),
            style: _theme.textTheme.headline6?.copyWith(color: greySwatch[50]),
          ),
          SizedBox(width: 5),
          Icon(Icons.star, color: greySwatch[50], size: 18),
        ],
      ),
    );
  }

  _buildLocation() {
    final restaurant = widget.restaurant;
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
              restaurant.address ?? 'Unknown!',
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
}
