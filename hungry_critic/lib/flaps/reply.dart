import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../blocs/review.dart';
import '../models/review.dart';
import '../routes/restaurants/common.dart';
import '../shared/colors.dart';
import '../shared/context.dart';
import 'creation_flap.dart';

class ReplyForm extends StatefulWidget {
  ReplyForm({Key? key, required this.review}) : super(key: key);

  final Review review;

  @override
  _ReplyFormState createState() => _ReplyFormState();
}

class _ReplyFormState extends EntityCreator<ReplyForm> {
  late ThemeData _theme;
  late Size _screen;

  late ReviewBloc _rBloc;

  late double _rating;

  final _replyC = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _rating = widget.review.rating;

    final reply = widget.review.reply;
    _replyC.text = reply ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _screen = MediaQuery.of(context).size;

    _rBloc = BlocsContainer.of(context).reBloc;
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _screen.width * 0.075),
        child: Column(
          children: [
            Text(
              review.reply != null ? 'Update Reply' : 'Write Reply',
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
            Text(review.review ?? '', style: _theme.textTheme.bodyText1),
            SizedBox(height: 20),
            TextFormField(
              controller: _replyC,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(15),
                hintText: 'Hi, thanks for the...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7.5),
                  borderSide: BorderSide(width: 1.5, color: greySwatch[300]),
                ),
              ),
              maxLines: null,
              minLines: 2,
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
            Text('THE RATING', style: _theme.textTheme.bodyText2),
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
    final rating = widget.review.rating;
    final iLimit = rating * 2;
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
          color: index < iLimit ? findColor(rating) : greySwatch[300],
        ),
      ),
    );
  }

  _selectSlice(int index) {
    setState(() => _rating = (index / 2) + 0.5);
  }

  @override
  FutureOr<SubmitStatus> submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return SubmitStatus.INVALID;
    return _rBloc
        .updateReply(widget.review, _replyC.text)
        .then((_) => SubmitStatus.SUCCESS)
        .catchError((_) => SubmitStatus.FAIL);
  }
}
