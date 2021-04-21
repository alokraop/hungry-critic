import 'package:flutter/material.dart';

import '../../blocs/pending_review.dart';
import '../../flaps/creation_flap.dart';
import '../../models/review.dart';
import '../../shared/colors.dart';
import '../../shared/context.dart';
import 'review_card.dart';

class ReviewsList extends StatefulWidget {
  ReviewsList({Key? key}) : super(key: key);

  @override
  _ReviewsListState createState() => _ReviewsListState();
}

class _ReviewsListState extends State<ReviewsList> {
  late PendingReviewBloc _bloc;

  late ThemeData _theme;

  final _controller = ScrollController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _bloc = BlocsContainer.of(context).pBloc;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bloc.reviews,
      initialData: <Review>[],
      builder: (BuildContext context, AsyncSnapshot<List<Review>> snapshot) {
        final data = snapshot.data;
        if (data == null) return Container();
        return SafeArea(
          child: Column(
            children: [
              if (data.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.5, top: 7.5, bottom: 15),
                      child: Text(
                        'New Reviews',
                        style: _theme.textTheme.headline5?.copyWith(
                          fontWeight: FontWeight.w300,
                          color: swatch[600],
                        ),
                      ),
                    ),
                  ],
                ),
              Expanded(child: _buildReviews(data)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviews(List<Review> reviews) {
    return ListView.builder(
      controller: _controller,
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ReviewCard(
          review: review,
          onReply: () => _startReply(review),
        );
      },
    );
  }

  _startReply(Review review) {
    Navigator.of(context).push(CreateEntity(type: Entity.REPLY, entity: review));
  }
}
