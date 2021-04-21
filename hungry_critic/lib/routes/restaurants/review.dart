import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/review.dart';
import '../../shared/colors.dart';
import 'common.dart';

class ReviewView extends StatelessWidget {
  const ReviewView({Key? key, required this.review}) : super(key: key);

  final Review review;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final format = DateFormat.yMd();
    return Column(
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 7.5),
              child: Text(
                format.format(review.dateOfVisit),
                style: _theme.textTheme.caption?.copyWith(
                  color: greySwatch[400],
                ),
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
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            review.review,
            style: _theme.textTheme.bodyText2,
          ),
        ),
      ],
    );
  }
}
