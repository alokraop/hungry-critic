import 'package:rxdart/rxdart.dart';

import '../apis/restaurant.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import 'account.dart';

const limit = 10;

class RestaurantBloc {
  RestaurantBloc(this.aBloc) : api = RestaurantApi(aBloc.config, aBloc.token);

  final RestaurantApi api;

  final AccountBloc aBloc;

  List<String> _restaurants = [];

  Map<String, Restaurant> _rMap = {};

  final _rSubject = BehaviorSubject<List<String>>();

  Stream<List<String>> get restaurants => _rSubject.stream;

  Future init() {
    _restaurants = [];
    return _load();
  }

  Future<int> _load([Map<String, dynamic>? query]) async {
    final rs = await api.findAll(query);
    rs.forEach((r) => _rMap[r.id] = r);
    _restaurants.addAll(rs.map((r) => r.id).toList());
    _publish();
    return rs.length;
  }

  Future<bool> loadMore() async {
    final query = {
      'offset': _restaurants.length.toString(),
      'limit': limit.toString(),
    };
    final length = await _load(query);
    return length == limit;
  }

  Restaurant? find(String id) => _rMap[id];

  Future createNew(Restaurant r) async {
    final restaurant = await api.createNew(r);
    _restaurants.add(restaurant.id);
    _rMap[restaurant.id] = restaurant;
    _publish();
  }

  Future update(Restaurant restaurant) async {
    _rMap[restaurant.id] = restaurant;
    _publish();
    return api.update(restaurant);
  }

  _publish() {
    _rSubject.sink.add(_restaurants);
  }

  dispose() {
    _rSubject.close();
  }

  Future deleteRestaurant(Restaurant restaurant) async {
    _restaurants.remove(restaurant.id);
    _rMap.remove(restaurant.id);
    _publish();
    return api.delete(restaurant.id);
  }

  void addReview(Review review) {
    final restaurant = _rMap[review.restaurant];
    if (restaurant == null) return;
    _addReview(restaurant, review);

    final best = restaurant.bestReview?.rating ?? 0;
    if (best <= review.rating) {
      restaurant.bestReview = review;
    }

    final worst = restaurant.worstReview?.rating ?? 5;
    if (worst >= review.rating) {
      restaurant.worstReview = review;
    }
    _publish();
  }

  _addReview(Restaurant restaurant, Review review) {
    final aggregate = restaurant.averageRating * restaurant.totalRatings;
    restaurant.totalRatings += 1;
    restaurant.averageRating = (aggregate + review.rating) / restaurant.totalRatings;
  }

  void deleteReview(Review review, Review? best, Review? worst) {
    final restaurant = _rMap[review.restaurant];
    if (restaurant == null) return;
    _deleteReview(restaurant, review);

    restaurant.bestReview = best;
    restaurant.worstReview = worst;
    _publish();
  }

  _deleteReview(Restaurant restaurant, Review review) {
    final aggregate = restaurant.averageRating * restaurant.totalRatings;
    restaurant.totalRatings -= 1;

    int total = restaurant.totalRatings;
    if (total == 0) total += 1;
    restaurant.averageRating = (aggregate - review.rating) / total;
  }

  void updateReview(Review review, Review? oldReview, Review? best, Review? worst) {
    final restaurant = _rMap[review.restaurant];
    if (restaurant == null) return;

    if (oldReview != null) _deleteReview(restaurant, oldReview);
    _addReview(restaurant, review);

    restaurant.bestReview = best;
    restaurant.worstReview = worst;
    _publish();
  }

  void updateReply(Review review) {
    final restaurant = _rMap[review.restaurant];
    if (restaurant == null) return;

    if (restaurant.bestReview?.author == review.author) {
      restaurant.bestReview = review;
    }
    if (restaurant.worstReview?.author == review.author) {
      restaurant.worstReview = review;
    }

    _publish();
  }

  Future deleteReviews(String id) {
    return init();
  }

  Future deleteRestaurants(String id) async {
    _restaurants = _restaurants.where((rId) => _rMap[rId]?.owner != id).toList();
    _publish();
  }
}
