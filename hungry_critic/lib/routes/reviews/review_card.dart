import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hungry_critic/shared/context.dart';

import '../../models/review.dart';
import '../../shared/colors.dart';
import '../restaurants/review.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    Key? key,
    required this.review,
    this.onReply,
  }) : super(key: key);

  final Review review;

  final Function()? onReply;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
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
      child: _buildCard(context),
    );

    return Container(
      margin: EdgeInsets.only(left: 12.5, right: 12.5, bottom: 20),
      child: content,
    );
  }

  Widget _buildCard(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.5),
        ReviewView(review: review),
        Padding(
          padding: const EdgeInsets.only(left: 7.5, right: 7.5, top: 5),
          child: Divider(thickness: 1),
        ),
        _buildActions(context),
      ],
    );
  }

  _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = BlocsContainer.of(context).rBloc;
    final name = bloc.find(review.restaurant)?.name ?? review.restaurant;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              name,
              style: theme.textTheme.bodyText2?.copyWith(
                color: greySwatch[400],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        _buildReply(context),
      ],
    );
  }

  _buildReply(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onReply,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 12.5, left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.reply, color: swatch, size: 20),
            SizedBox(width: 5),
            Text(
              'Reply',
              style: theme.textTheme.bodyText2?.copyWith(color: swatch),
            ),
          ],
        ),
      ),
    );
  }
}
