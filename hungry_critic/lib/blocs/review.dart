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

  List<Review> _reviews = [];

  final _rSubject = BehaviorSubject<List<Review>>();

  Stream<List<Review>> get reviews => _rSubject.stream;

  Future push(Restaurant restaurant) async {
    _restaurant = restaurant;
    _reviews = await api.findAllReviews(restaurant.id);
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
    _reviews.insert(0, review);
    _publish();
    rBloc.addReview(review);
    return api.createReview(review);
  }

  Future update(Review review) async {
    _publish();
    rBloc.updateReview(review, _findBest(), _findWorst());
    return api.updateReview(review);
  }

  _publish() {
    _rSubject.sink.add(_reviews);
  }

  dispose() {
    _rSubject.close();
  }

  Future delete(Review review) async {
    _reviews.removeWhere((r) => r.author == review.author);
    _publish();
    rBloc.deleteReview(review, _findBest(), _findWorst());
    return api.deleteReview(review);
  }

  Review? _findBest() {
    Review? best;
    for (final review in _reviews) {
      if (review.rating >= (best?.rating ?? 0)) {
        best = review;
      }
    }
    return best;
  }

  Review? _findWorst() {
    Review? worst;
    for (final review in _reviews) {
      if (review.rating <= (worst?.rating ?? 5)) {
        worst = review;
      }
    }
    return worst;
  }
}
