import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../blocs/account.dart';
import '../blocs/review.dart';
import '../models/review.dart';
import '../routes/restaurants/common.dart';
import '../shared/colors.dart';
import '../shared/context.dart';
import 'creation_flap.dart';

class ReviewForm extends StatefulWidget {
  ReviewForm({Key? key, this.review}) : super(key: key);

  final Review? review;

  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends EntityCreator<ReviewForm> {
  late ThemeData _theme;
  late Size _screen;

  late AccountBloc _aBloc;
  late ReviewBloc _rBloc;

  double _rating = 5;
  final _reviewC = TextEditingController();
  DateTime _date = DateTime.now();

  final _formKey = GlobalKey<FormState>();

  Review? _existing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _screen = MediaQuery.of(context).size;

    final c = BlocsContainer.of(context);
    _rBloc = c.reBloc;
    _aBloc = c.aBloc;

    final oldReview = widget.review ?? _rBloc.find(_aBloc.account.id);
    if (oldReview != null) {
      _existing = oldReview;
      _rating = oldReview.rating;
      _reviewC.text = oldReview.review;
      _date = oldReview.dateOfVisit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _screen.width * 0.075),
        child: Column(
          children: [
            Text(
              _existing != null ? 'Update Review' : 'Create Review',
              style: _theme.textTheme.headline5?.copyWith(
                color: swatch,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _screen.width * 0.075),
              child: _buildRating(),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _reviewC,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(15),
                hintText: 'This place was...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5),
                  borderSide: BorderSide(width: 1.5, color: greySwatch[300]),
                ),
              ),
              maxLines: null,
              minLines: 5,
              validator: _validateReview,
            ),
            SizedBox(height: 12.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DATE OF VISIT', style: _theme.textTheme.bodyText2),
                _buildDate(_date, (d) => setState(() => _date = d)),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  _buildRating() {
    final rating = _rating.toStringAsFixed(1);
    final color = findColor(_rating);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('MY RATING', style: _theme.textTheme.bodyText2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rating,
                  style: _theme.textTheme.bodyText1?.copyWith(color: color),
                ),
                Icon(Icons.star, color: color),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        LayoutBuilder(builder: (c, cons) {
          final sWidth = (cons.maxWidth / 10) - 4;
          final width = min(sWidth, 30.0);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(10, (i) => i).map((i) => _buildSlice(i, width)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildSlice(int index, double width) {
    final iLimit = _rating * 2;
    return InkWell(
      onTap: () => _selectSlice(index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2),
        width: width,
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(
            left: index == 0 ? Radius.circular(7.5) : Radius.zero,
            right: index == 9 ? Radius.circular(7.5) : Radius.zero,
          ),
          color: index < iLimit ? findColor(_rating) : greySwatch[300],
        ),
      ),
    );
  }

  _selectSlice(int index) {
    setState(() => _rating = (index / 2) + 0.5);
  }

  Widget _buildDate(DateTime date, Function onTap) {
    final label = DateFormat.yMd().format(date);
    changeDate() async {
      final newDate = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2019),
        lastDate: DateTime.now(),
      );
      if (newDate != null) onTap(newDate);
    }

    return InkWell(
      onTap: changeDate,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.5, vertical: 5),
        decoration: BoxDecoration(
          color: swatch[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: _theme.textTheme.subtitle1?.copyWith(color: greySwatch[50]),
            ),
            SizedBox(width: 5),
            Icon(
              Icons.edit,
              color: greySwatch[50],
              size: 17.5,
            ),
          ],
        ),
      ),
    );
  }

  String? _validateReview(String? review) {
    if (review?.isEmpty ?? true) return 'You need to add a review';
    return null;
  }

  @override
  FutureOr<SubmitStatus> submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return SubmitStatus.INVALID;
    final oldReview = _existing;
    if (oldReview == null) {
      final review = Review(
        author: _aBloc.account.id,
        authorName: _aBloc.account.name ?? 'Unknown',
        rating: _rating,
        review: _reviewC.text,
        dateOfVisit: _date,
      );
      return _rBloc
          .createNew(review)
          .then((_) => SubmitStatus.SUCCESS)
          .catchError((_) => SubmitStatus.FAIL);
    } else {
      final review = Review(
        author: oldReview.author,
        authorName: oldReview.authorName,
        rating: _rating,
        review: _reviewC.text,
        dateOfVisit: _date,
      )..restaurant = oldReview.restaurant;
      return _rBloc
          .update(review)
          .then((_) => SubmitStatus.SUCCESS)
          .catchError((_) => SubmitStatus.FAIL);
    }
  }
}
