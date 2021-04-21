import 'package:rxdart/rxdart.dart';

import '../apis/restaurant.dart';
import '../apis/review.dart';
import '../models/review.dart';
import 'account.dart';
import 'restaurant.dart';

class PendingReviewBloc {
  PendingReviewBloc(this.aBloc, this.rBloc)
      : _api = ReviewApi(aBloc.config, aBloc.token),
        _rApi = RestaurantApi(aBloc.config, aBloc.token);

  final ReviewApi _api;

  final RestaurantApi _rApi;

  final AccountBloc aBloc;

  final RestaurantBloc rBloc;

  List<Review> _reviews = [];

  final _rSubject = BehaviorSubject<List<Review>>();

  Stream<List<Review>> get reviews => _rSubject.stream;

  Future init() {
    _reviews = [];
    return _load();
  }

  Future<int> _load([Map<String, dynamic>? query]) async {
    final rs = await _api.findAll(query);
    rs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _reviews.addAll(rs);
    _publish();
    return rs.length;
  }

  Future<bool> loadMore() async {
    final query = {
      'offset': _reviews.length.toString(),
      'limit': limit.toString(),
    };
    final length = await _load(query);
    return length == limit;
  }

  Future addComment(Review review, String reply) async {
    _reviews.remove(review);
    review.reply = reply;
    _publish();
    return Future.wait([
      rBloc.init(),
      _rApi.addReply(review),
    ]);
  }

  _publish() {
    _rSubject.sink.add(_reviews);
  }

  dispose() {
    _rSubject.close();
  }
}
