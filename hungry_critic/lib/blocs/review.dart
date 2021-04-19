import 'package:rxdart/rxdart.dart';

import '../apis/restaurant.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import 'account.dart';
import 'restaurant.dart';

class ReviewBloc {
  ReviewBloc(this.aBloc, this.rBloc) : api = RestaurantApi(aBloc.config, aBloc.token);

  final RestaurantApi api;

  final AccountBloc aBloc;

  final RestaurantBloc rBloc;

  Restaurant? _restaurant;

  List<String> _reviews = [];

  Map<String, Review> _rMap = {};

  final _rSubject = BehaviorSubject<List<String>>();

  Stream<List<String>> get reviews => _rSubject.stream;

  Review? find(String id) => _rMap[id];

  Future push(Restaurant restaurant) async {
    _restaurant = restaurant;
    final rs = await api.findAllReviews(restaurant.id);
    rs.forEach((r) => _rMap[r.author] = r);
    rs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _reviews = rs.map((r) => r.author).toList();
    _publish();
  }

  pop() {
    _restaurant = null;
    _reviews = [];
    _publish();
  }

  Future createNew(Review review) {
    final restaurant = _restaurant;
    if (restaurant == null) throw Exception('Cannot create a review!');
    review.restaurant = restaurant.id;
    _reviews.insert(0, review.author);
    _rMap[review.author] = review;
    _publish();
    rBloc.addReview(review);
    return api.createReview(review);
  }

  Future update(Review review) async {
    final oldReview = _rMap[review.author];
    _rMap[review.author] = review;
    _publish();
    rBloc.updateReview(review, oldReview, _findBest(), _findWorst());
    return api.updateReview(review);
  }

  _publish() {
    _rSubject.sink.add(_reviews);
  }

  dispose() {
    _rSubject.close();
  }

  Future delete(Review review) async {
    _reviews.remove(review.author);
    _publish();
    rBloc.deleteReview(review, _findBest(), _findWorst());
    return api.deleteReview(review);
  }

  Review? _findBest() {
    Review? best;
    for (final id in _reviews) {
      final review = _rMap[id];
      final cBest = best?.rating ?? 0;
      if (review != null && review.rating >= cBest) {
        best = review;
      }
    }
    return best;
  }

  Review? _findWorst() {
    Review? worst;
    for (final id in _reviews) {
      final review = _rMap[id];
      final cWorst = worst?.rating ?? 5;
      if (review != null && review.rating <= cWorst) {
        worst = review;
      }
    }
    return worst;
  }

  Future updateReply(Review review, String reply) async {
    review.reply = reply;
    _rMap[review.author] = review;
    _publish();
    rBloc.updateReply(review);
    return api.addReply(review);
  }

  Future deleteReply(Review review) async {
    review.reply = null;
    _rMap[review.author] = review;
    _publish();
    rBloc.updateReply(review);
    return api.deleteReply(review);
  }
}
