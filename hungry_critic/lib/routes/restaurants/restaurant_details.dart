import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hungry_critic/blocs/review.dart';
import 'package:hungry_critic/models/review.dart';
import 'package:hungry_critic/shared/timestamp.dart';

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
  late ReviewBloc _rBloc;

  late Restaurant _restaurant;

  PageController _pageC = PageController();
  StreamSubscription<List<String>>? _sub;

  bool _highlights = true;

  bool get canModify {
    final account = _aBloc.account;
    switch (account.role) {
      case UserRole.ADMIN:
        return true;
      case UserRole.USER:
        return false;
      case UserRole.OWNER:
        return account.id == widget.restaurant.owner;
    }
  }

  bool get canReview => _aBloc.account.role == UserRole.USER;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _bloc = BlocsContainer.of(context).rBloc;
    _aBloc = BlocsContainer.of(context).aBloc;
    _rBloc = BlocsContainer.of(context).reBloc;
    if (_sub == null) {
      _restaurant = widget.restaurant;
      _sub = _bloc.restaurants.listen((_) {
        final restaurant = _bloc.find(_restaurant.id);
        if (restaurant != null) _restaurant = restaurant;
        setState(() {});
      });
    }
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
                    padding: EdgeInsets.only(top: 25),
                    child: Column(
                      children: [
                        _buildInfo(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Divider(thickness: 0.75),
                        ),
                        _buildLocation(),
                        _buildTimings(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        children: [
          Expanded(child: _buildTitle()),
          _buildRating(),
        ],
      ),
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
      padding: const EdgeInsets.only(bottom: 15, left: 10, right: 15),
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
      padding: const EdgeInsets.only(top: 15, left: 10, right: 15),
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
          margin: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: _buildTabs(),
        ),
        Expanded(
          child: _buildPages(),
        ),
      ],
    );
  }

  Widget _buildPages() {
    final mine = _rBloc.find(_aBloc.account.id);
    final best = _restaurant.bestReview;
    final worst = _restaurant.worstReview;
    return PageView(
      controller: _pageC,
      children: [
        ListView(
          padding: EdgeInsets.symmetric(horizontal: 15),
          children: [
            SizedBox(height: 20),
            if (mine != null) _buildHighlight('MY REVIEW', mine),
            if (best != null) _buildHighlight('BEST REVIEW', best),
            if (worst != null) _buildHighlight('WORST REVIEW', worst),
          ],
        ),
        StreamBuilder(
          stream: _rBloc.reviews,
          initialData: <String>[],
          builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            final data = snapshot.data;
            if (data == null) return Container();
            return ListView(
              padding: EdgeInsets.symmetric(horizontal: 32.5),
              children: [
                SizedBox(height: 20),
                ...data
                    .map((id) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: _buildReview(_rBloc.find(id)),
                        ))
                    .toList()
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () => setState(() {
              _highlights = true;
              _pageC.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
            }),
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
            onTap: () => setState(() {
              _highlights = false;
              _pageC.animateToPage(1, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
            }),
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
    );
  }

  _buildHighlight(String label, Review review) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          SizedBox(height: 10),
          _buildReview(review),
        ],
      ),
    );
  }

  Widget _buildReview(Review? review) {
    if (review == null) return Container();
    final content = review.review;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    review.authorName,
                    style: _theme.textTheme.subtitle1?.copyWith(color: greySwatch[800]),
                  ),
                  SizedBox(width: 5),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Timestamp(time: review.timestamp, relative: true, ignoreDate: false),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.5),
                color: findColor(review.rating),
              ),
              padding: EdgeInsets.symmetric(horizontal: 7.5, vertical: 3),
              child: Text(
                review.rating.toStringAsFixed(1),
                style: _theme.textTheme.bodyText2?.copyWith(color: greySwatch[50]),
              ),
            ),
          ],
        ),
        if (content != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              content,
              style: _theme.textTheme.bodyText2,
            ),
          ),
        if (isAdmin()) _buildOptions(review),
        _buildReply(review),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
          child: Divider(thickness: 0.75),
        ),
      ],
    );
  }

  _startEdit() {
    Navigator.of(context).push(
      CreateEntity(type: Entity.RESTAURANT, entity: _restaurant),
    );
  }

  _startDelete() {
    _showDialog('This will delete the restaurant and all its reviews', _delete);
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

  _startReview([Review? review]) {
    Navigator.of(context).push(CreateEntity(type: Entity.REVIEW, entity: review));
  }

  _buildReply(Review review) {
    final reply = review.reply;
    if (reply == null) {
      final account = _aBloc.account;
      switch (account.role) {
        case UserRole.USER:
        case UserRole.ADMIN:
          return Container();
        case UserRole.OWNER:
          if (account.id != _restaurant.owner) return Container();
          return _buildRButton(review);
      }
    } else {
      return _buildRContent(review, reply);
    }
  }

  bool canEditReply() {
    final account = _aBloc.account;
    switch (account.role) {
      case UserRole.USER:
        return false;
      case UserRole.OWNER:
        return account.id == _restaurant.owner;
      case UserRole.ADMIN:
        return true;
    }
  }

  bool isAdmin() => _aBloc.account.role == UserRole.ADMIN;

  _buildRButton(Review review) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _startReply(review),
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.reply, color: swatch),
                SizedBox(width: 5),
                Text(
                  'Reply',
                  style: _theme.textTheme.bodyText1?.copyWith(
                    color: swatch,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildRContent(Review review, String reply) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Text(
              'MANAGEMENT RESPONSE:',
              style: _theme.textTheme.bodyText2?.copyWith(
                fontWeight: FontWeight.w500,
                color: greySwatch[700],
              ),
            ),
          ),
          Text(
            reply,
            style: _theme.textTheme.bodyText2?.copyWith(
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (canEditReply())
            Row(
              children: [
                _buildAction('Edit', Icons.edit, () => _startReply(review)),
                if (isAdmin())
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: _buildAction('Delete', Icons.delete, () => _deleteReply(review)),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  _deleteReply(Review review) {
    _showDialog(
      'The reply cannot be restored',
      () => _rBloc.deleteReply(review),
    );
  }

  _buildOptions(Review review) {
    return Row(
      children: [
        _buildAction('Edit', Icons.edit, () => _startReview(review)),
        SizedBox(width: 15),
        _buildAction('Delete', Icons.delete, () => {}),
      ],
    );
  }

  _buildAction(String label, IconData icon, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: swatch, size: 18),
            SizedBox(width: 5),
            Text(
              label,
              style: _theme.textTheme.bodyText2?.copyWith(
                color: swatch,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _startReply(Review review) {
    Navigator.of(context).push(CreateEntity(type: Entity.REPLY, entity: review));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
